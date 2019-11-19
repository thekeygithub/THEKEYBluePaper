﻿using System.Windows;
using System.Windows.Controls;
using thinWallet.dapp_plat;
using System.Collections.Generic;
using System;
using System.Linq;
using System.Text;

namespace thinWallet
{
    /// <summary>
    /// Window_thinwallet.xaml 的交互逻辑
    /// </summary>
    public partial class Window_thinwallet : Window
    {
        DApp_Plat dapp_plat = new DApp_Plat();
        bool dapp_Init = false;
        public class DappValue
        {
            public object value;
            public bool error = false;
            public override string ToString()
            {
                if (value == null)
                    return "<null>";

                return value.ToString();
            }
        }
        Dictionary<string, DappValue> dapp_values = new Dictionary<string, DappValue>();
        //change dapp function
        private void dappfuncs_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            var plugin = dappfuncs.Tag as DApp_SimplePlugin;
            if (plugin == null) return;
            if (dappfuncs.SelectedItem == null) return;

            var func = (dappfuncs.SelectedItem as TabItem).Tag as DApp_Func;
            if (func == null)
                return;
            var items = (((dappfuncs.SelectedItem as TabItem).Content as ScrollViewer).Content as Canvas).Children;
            foreach (var input in func.inputs)
            {
                if (string.IsNullOrEmpty(input.id) == false)
                {
                    if (dapp_values.ContainsKey(input.id) == false)
                    {
                        dapp_values[input.id] = new DappValue();
                        dapp_values[input.id].value = new MyJson.JsonNode_ValueString(input.value).ToString();
                        dapp_values[input.id].error = false;
                    }
                }
            }
            foreach (FrameworkElement ui in items)
            {
                if (ui.Tag is DAppFunc_Input)
                {
                    var input = ui.Tag as DAppFunc_Input;
                    try
                    {
                        var value = dapp_getValue(ui, input.type);
                        this.dapp_values[input.id].value = value;
                        this.dapp_values[input.id].error = false;
                    }
                    catch (Exception err)
                    {
                        this.dapp_values[input.id].value = err.Message;
                        this.dapp_values[input.id].error = true;
                    }
                }
            }
            if (func.call.type == DAppFunc_Call.Type.sendrawtransaction)
            {
                btnMakeTran.Visibility = Visibility.Visible;
                btnDapp.Content = "SendRaw(GAS)";
            }
            else if (func.call.type == DAppFunc_Call.Type.getstorage)
            {
                btnMakeTran.Visibility = Visibility.Hidden;
                btnDapp.Content = "GetStorage(Free)";
            }
            else if (func.call.type == DAppFunc_Call.Type.invokescript)
            {
                btnMakeTran.Visibility = Visibility.Hidden;
                btnDapp.Content = "InvokeScript(Free)";
            }
            dapp_updateValuesUI();
        }

        //UI execute pressed
        private void Execute_Dapp_Function(object sender, RoutedEventArgs e)
        {
            var plugin = dappfuncs.Tag as DApp_SimplePlugin;
            if (plugin == null)
                return;
            var func = (dappfuncs.SelectedItem as TabItem).Tag as DApp_Func;
            if (func.call.type == DAppFunc_Call.Type.getstorage)
            {
                dapp_getStorage(func);
            }
            else if (func.call.type == DAppFunc_Call.Type.invokescript)
            {
                dapp_invokeScript(func);
            }
            else if (func.call.type == DAppFunc_Call.Type.sendrawtransaction)
            {
                dapp_sendrawtransaction(func);
            }
        }
        private void Execute_Dapp_Function_GenOnly(object sender, RoutedEventArgs e)
        {
            var plugin = dappfuncs.Tag as DApp_SimplePlugin;
            if (plugin == null)
                return;
            var func = (dappfuncs.SelectedItem as TabItem).Tag as DApp_Func;
            if (func.call.type == DAppFunc_Call.Type.sendrawtransaction)
            {
                dapp_sendrawtransaction(func, true);
                tabMain.SelectedIndex = 0;
            }

        }
        private void dapp_getStorage(DApp_Func func)
        {
            try
            {
                var json = func.call.scriptparam;
                var scripthash = dapp_getCallParam(json[0].AsString());
                var key = dapp_getCallParam(json[1].AsString());
                var result = rpc_getStorage(scripthash, key);
                if (result == null)
                    this.dapp_result_raw.Text = "(null)";
                else
                    this.dapp_result_raw.Text = result;

                this.dapp_result.Text = "";
                if (func.results.Length > 0)
                {
                    var outvalue = "";
                    try
                    {
                        MyJson.JsonNode_Object item = new MyJson.JsonNode_Object();
                        item.SetDictValue("type", "ByteArray");
                        item.SetDictValue("value", result);
                        outvalue = dapp_getResultValue(func.results[0].type, item);
                    }
                    catch (Exception err)
                    {
                        outvalue = "err:" + err.Message;
                    }
                    this.dapp_result.Text += (func.results[0].desc + "=" + outvalue) + "\r\n";
                }
            }
            catch (Exception err)
            {
                this.dapp_result_raw.Text = "error=" + err.Message + "\r\n" + err.StackTrace;
            }
        }
        void dapp_EmitParam(ThinNeo.ScriptBuilder sb, MyJson.IJsonNode param)
        {
            if (param is MyJson.JsonNode_ValueNumber)//bool 或小整数
            {
                sb.EmitParamJson(param);
            }
            else if (param is MyJson.JsonNode_Array)
            {
                var list = param.AsList();
                for (var i = list.Count - 1; i >= 0; i--)
                {
                    dapp_EmitParam(sb, list[i]);
                }
                sb.EmitPushNumber(param.AsList().Count);
                sb.Emit(ThinNeo.VM.OpCode.PACK);
            }
            else if (param is MyJson.JsonNode_ValueString)//复杂格式
            {
                var str = param.AsString();
                var bytes = dapp_getCallParam(str);
                sb.EmitPushBytes(bytes);
            }
            else
            {
                throw new Exception("should not pass a {}");
            }
        }
        MyJson.JsonNode_Object getJsonResult(MyJson.JsonNode_Array json, string pos)
        {
            var pp = pos.Split(new char[] { '[', ']' }, StringSplitOptions.RemoveEmptyEntries);

            if (pp[0] == "result")
            {
                MyJson.IJsonNode value = json;

                for (var i = 1; i < pp.Length; i++)
                {
                    if (value is MyJson.JsonNode_Object && value.AsDict()["type"].AsString() == "Array")
                    {
                        value = value.AsDict()["value"];
                    }
                    var index = int.Parse(pp[i]);
                    value = value.AsList()[index];
                }
                return value.AsDict();

            }
            return null;
        }
        private void dapp_invokeScript(DApp_Func func)
        {
            try
            {
                var hash = dapp_getCallParam(func.call.scriptcall);
                var scrb = new ThinNeo.ScriptBuilder();
                var jsonps = func.call.scriptparam;
                for (var i = jsonps.Length - 1; i >= 0; i--)
                {
                    dapp_EmitParam(scrb, jsonps[i]);
                }
                scrb.EmitAppCall(hash);


                var callstr = ThinNeo.Helper.Bytes2HexString(scrb.ToArray());
                var str = WWW.MakeRpcUrl(labelApi.Text, "invokescript", new MyJson.JsonNode_ValueString(callstr));
                var result = WWW.GetWithDialog(this, str);

                this.dapp_result.Text = "";


                if (result == null)
                    this.dapp_result_raw.Text = "(null)";
                else
                {
                    var json = MyJson.Parse(result).AsDict();
                    if (json.ContainsKey("error"))
                    {
                        this.dapp_result_raw.Text = json["error"].ToString();

                    }
                    else
                    {
                        StringBuilder sb = new StringBuilder();
                        //json["result"].AsDict().ConvertToStringWithFormat(sb, 4);
                        this.dapp_result_raw.Text = sb.ToString();
                        //var gas = json["result"].AsDict()["gas_consumed"].ToString();
                        //this.dapp_result.Items.Add("Fee:" + gas);
                        //var state = json["result"].AsDict()["state"].ToString();
                        //this.dapp_result.Items.Add("State:" + state);
                        var stack = json["result"].AsList()[0].AsDict()["stack"].AsList();
                        this.dapp_result.Text += ("StackCount=" + stack.Count) + "\r\n";
                        for (var i = 0; i < func.results.Length; i++)
                        {
                            var jsonresult = getJsonResult(stack, func.results[i].pos);
                            if (jsonresult == null)
                            {
                                this.dapp_result.Text += (func.results[i].desc + "=" + "<miss>") + "\r\n";
                            }
                            else
                            {
                                try
                                {
                                    var outvalue = dapp_getResultValue(func.results[i].type, jsonresult);
                                    this.dapp_result.Text += (func.results[i].desc + "=" + outvalue) + "\r\n";
                                }
                                catch
                                {
                                    this.dapp_result.Text += (func.results[i].desc + "=" + "<error>") + "\r\n";

                                }
                            }
                        }


                    }
                }


            }
            catch (Exception err)
            {
                this.dapp_result_raw.Text = "error=" + err.Message + "\r\n" + err.StackTrace;
            }
        }

        private void dapp_sendrawtransaction(DApp_Func func, bool onlyMakeTran = false)
        {
            try
            {
                dapp_result.Text = "";
                dapp_result_raw.Text = "";
                //fill script
                if (string.IsNullOrEmpty(func.call.scriptcall))
                {
                    this.lastScript = null;
                    this.tabCType.SelectedIndex = 0;
                    this.updateScript();
                    lastFee = 0;
                    labelFee.Text = "Fee:" + lastFee;
                }
                else
                {
                    var hash = dapp_getCallParam(func.call.scriptcall);
                    var scrb = new ThinNeo.ScriptBuilder();
                    var jsonps = func.call.scriptparam;
                    for (var i = jsonps.Length - 1; i >= 0; i--)
                    {
                        dapp_EmitParam(scrb, jsonps[i]);
                    }
                    scrb.EmitAppCall(hash);
                    this.lastScript = scrb.ToArray();
                    this.tabCType.SelectedIndex = 1;
                    this.updateScript();
                    lastFee = (decimal)func.call.scriptfee;
                    labelFee.Text = "Fee:" + lastFee;
                }
                //fill input
                this.listInput.Items.Clear();
                foreach (var coin in func.call.coins)
                {
                    var hash = dapp_getCallParam(coin.scripthash);
                    var value = coin.value;
                    tx_fillInputs(hash, coin.asset, value);
                }
                //fill output
                this.updateOutput();

                //生成交易,拼签名
                var tran = this.GenTran();
                if (tran == null)
                    return;
                this.lastTranMessage = tran.GetMessage();

                //处理鉴证
                foreach (var coin in func.call.witnesses)
                {
                    byte[] vscript = dapp_getCallParam(coin.vscript);
                    var hash = ThinNeo.Helper.GetScriptHashFromScript(vscript);
                    var addr = ThinNeo.Helper.GetAddressFromScriptHash(hash);
                    ThinNeo.Witness wit = null;
                    foreach (ThinNeo.Witness w in listWitness.Items)
                    {
                        if (w.Address == addr)
                        {
                            wit = w;
                            break;
                        }
                    }
                    if (wit == null)
                    {
                        wit = new ThinNeo.Witness();
                        wit.VerificationScript = vscript;
                        listWitness.Items.Add(wit);
                    }
                    ThinNeo.ScriptBuilder sb = new ThinNeo.ScriptBuilder();
                    for (var i = coin.iscript.Length - 1; i >= 0; i--)
                    {
                        dapp_EmitParam(sb, coin.iscript[i]);
                    }
                    wit.InvocationScript = sb.ToArray();

                }
                if (onlyMakeTran)
                {
                    return;
                }
                var ttran = this.signAndBroadcast();
                if (tran != null)
                {
                    this.dapp_result_raw.Text = "sendtran:" + ThinNeo.Helper.Bytes2HexString(ttran.GetHash());
                }
            }
            catch (Exception err)
            {
                this.dapp_result_raw.Text = "error=" + err.Message + "\r\n" + err.StackTrace;
            }
        }
        void tx_fillInputs(byte[] hash, string asset, ThinNeo.Fixed8 count)
        {
            var assetid = "";
            foreach (var item in Tools.CoinTool.assetUTXO)
            {
                if (item.Value == asset || item.Key == asset)
                {
                    assetid = item.Key;
                    break;
                }
            }
            var address = ThinNeo.Helper.GetAddressFromScriptHash(hash);
            var thispk = ThinNeo.Helper.GetPublicKeyFromPrivateKey(this.privatekey);
            var thisaddr = ThinNeo.Helper.GetAddressFromPublicKey(thispk);
            if (address == thisaddr)
            {
                var b = tx_fillThis(assetid, count);
                if (b == false)
                    throw new Exception("not have enough coin.");
            }


        }
        bool tx_fillThis(string assetid, ThinNeo.Fixed8 count)
        {
            if (assetid == "")
                throw new Exception("refresh utxo first.");

            var pubkey = ThinNeo.Helper.GetPublicKeyFromPrivateKey(this.privatekey);
            var hash = ThinNeo.Helper.GetScriptHashFromPublicKey(pubkey);
            foreach (var coins in this.myasset.allcoins)
            {
                if (coins.AssetID == assetid)
                {
                    coins.coins.Sort((a, b) =>
                    {
                        return Math.Sign(a.value - b.value);
                    });
                    decimal want = count;
                    decimal inputv = 0;
                    foreach (var c in coins.coins)
                    {
                        Tools.Input input = new Tools.Input();
                        input.Coin = c;
                        input.From = hash;
                        this.listInput.Items.Add(input);
                        inputv += c.value;
                        if (inputv > want)
                            break;
                    }
                    if (inputv < want)
                        return false;
                    else
                        return true;
                }
            }
            return false;
        }
        string rpc_getStorage(byte[] scripthash, byte[] key)
        {
            System.Net.WebClient wc = new System.Net.WebClient();
            var url = this.labelApi.Text;
            var shstr = ThinNeo.Helper.Bytes2HexString(scripthash.Reverse().ToArray());
            var keystr = ThinNeo.Helper.Bytes2HexString(key);
            var str = WWW.MakeRpcUrl(url, "getstorage", new MyJson.JsonNode_ValueString(shstr), new MyJson.JsonNode_ValueString(keystr));
            var result = WWW.GetWithDialog(this, str);
            if (result != null)
            {

                var json = MyJson.Parse(result);
                if (json.AsDict().ContainsKey("error"))
                    return null;
                var _result = json.AsDict()["result"].AsList();
                var script = _result[0].AsDict()["storagevalue"].AsString();
                return script;
            }
            return null;
        }

        byte[] dapp_getCallParam(string text)
        {
            var str = text;
            if (text.Contains("%"))
            {
                var ss = text.Split(new char[] { '%' }, StringSplitOptions.RemoveEmptyEntries);
                if (ss.Length != 2)
                {
                    throw new Exception("not a vaild text:" + text);
                }

                str = ss[0] + dapp_getRefValues(ss[1]);
            }
            var bytes = ThinNeo.ScriptBuilder.GetParamBytes(str);
            return bytes;
        }
        string dapp_getRefValues(string info)
        {
            var plugin = dappfuncs.Tag as DApp_SimplePlugin;
            var func = (dappfuncs.SelectedItem as TabItem).Tag as DApp_Func;

            info = info.Replace(" ", "");
            var pointstr = info.Split(new char[] { '.' }, StringSplitOptions.RemoveEmptyEntries);
            if (pointstr[0] == "consts")
            {
                if (plugin.consts.ContainsKey(pointstr[1]))
                {
                    return plugin.consts[pointstr[1]];
                }
                else
                {
                    throw new Exception("not have const:" + info);
                }
            }
            else if (pointstr[0] == "inputs")
            {
                if (this.dapp_values.ContainsKey(pointstr[1]))
                {
                    if (this.dapp_values[pointstr[1]].error == false)
                    {
                        var obj = this.dapp_values[pointstr[1]].value;
                        if (obj is ThinNeo.NNSUrl)
                        {
                            var url = obj as ThinNeo.NNSUrl;
                            if (pointstr[2] == "namehash")
                            {
                                return ThinNeo.Helper.Bytes2HexString(url.namehash);
                            }
                            if (pointstr[2] == "parenthash")
                            {
                                return ThinNeo.Helper.Bytes2HexString(url.parenthash);
                            }
                            if (pointstr[2] == "lastname")
                            {
                                return url.lastname;
                            }
                            throw new Exception("not suport for nns:" + pointstr[2]);

                        }
                        return this.dapp_values[pointstr[1]].ToString();
                    }
                    else
                    {
                        throw new Exception("value is in error:" + info);
                    }
                }
                else
                {
                    throw new Exception("not have inputs:" + info);
                }
            }
            else if (pointstr[0] == "keyinfo")
            {
                if (this.privatekey == null)
                {
                    throw new Exception("not load key.");
                }
                if (pointstr[1] == "pubkey")
                {
                    var pkey = ThinNeo.Helper.GetPublicKeyFromPrivateKey(this.privatekey);
                    return ThinNeo.Helper.Bytes2HexString(pkey);
                }
                else if (pointstr[1] == "script")
                {
                    var pkey = ThinNeo.Helper.GetPublicKeyFromPrivateKey(this.privatekey);
                    var hs = ThinNeo.Helper.GetScriptFromPublicKey(pkey);
                    return ThinNeo.Helper.Bytes2HexString(hs);
                }
                else if (pointstr[1] == "scripthash")
                {
                    var pkey = ThinNeo.Helper.GetPublicKeyFromPrivateKey(this.privatekey);
                    var hs = ThinNeo.Helper.GetScriptHashFromPublicKey(pkey);
                    return ThinNeo.Helper.Bytes2HexString(hs);
                }
                else if (pointstr[1] == "signdata")
                {
                    var data = ThinNeo.Helper.Sign(this.lastTranMessage, this.privatekey);
                    return ThinNeo.Helper.Bytes2HexString(data);

                }
            }

            throw new Exception("not support it:" + info);

        }

        string dapp_getResultValue(string type, MyJson.JsonNode_Object result)
        {
            var rtype = result["type"].AsString();
            if (type == "string")
            {
                if (rtype == "ByteArray")
                {
                    var bts = ThinNeo.Helper.HexString2Bytes(result["value"].AsString());
                    return System.Text.Encoding.UTF8.GetString(bts);
                }
                throw new Exception("not support conver:" + rtype + "->" + type);
            }
            if (type == "bytes")
            {
                if (rtype == "ByteArray")
                {
                    var bts = result["value"].AsString();
                    return bts;
                }
                throw new Exception("not support conver:" + rtype + "->" + type);

            }
            if (type == "address")
            {
                if (rtype == "ByteArray")
                {
                    var bts = ThinNeo.Helper.HexString2Bytes(result["value"].AsString());
                    var addr = ThinNeo.Helper.GetAddressFromScriptHash(bts);

                    return addr;
                }
                throw new Exception("not support conver:" + rtype + "->" + type);

            }
            if (type == "int" || type == "integer")
            {
                if (rtype == "ByteArray")
                {
                    var bts = ThinNeo.Helper.HexString2Bytes(result["value"].AsString());
                    var n = new System.Numerics.BigInteger(bts);

                    return n.ToString();
                }
                throw new Exception("not support conver:" + rtype + "->" + type);

            }
            if (type == "hex" || type == "hexinteger" || type == "hexint")
            {
                var bts = ThinNeo.Helper.HexString2Bytes(result["value"].AsString());
                return ThinNeo.Helper.Bytes2HexString(bts.Reverse().ToArray());
            }
            if (type == "hex160" || type == "uint160" || type == "int160")
            {
                var bts = ThinNeo.Helper.HexString2Bytes(result["value"].AsString());
                if (bts.Length != 20)
                    throw new Exception("not uint160");
                return ThinNeo.Helper.Bytes2HexString(bts.Reverse().ToArray());
            }
            if (type == "hex256" || type == "uint256" || type == "int256")
            {
                var bts = ThinNeo.Helper.HexString2Bytes(result["value"].AsString());
                if (bts.Length != 32)
                    throw new Exception("not uint256");
                return ThinNeo.Helper.Bytes2HexString(bts.Reverse().ToArray());
            }
            throw new Exception("not support type:" + type);
        }

        object dapp_getValue(FrameworkElement ui, string type)
        {
            if (type == "string" || type == "str")
            {
                if ((ui is TextBlock))
                    return (ui as TextBlock).Text;
                if ((ui is TextBox))
                    return (ui as TextBox).Text;
                else
                    throw new Exception("not support");
            }
            else if (type == "address")
            {
                var str = "";
                if ((ui is TextBlock))
                    str = (ui as TextBlock).Text;
                else if ((ui is TextBox))
                    str = (ui as TextBox).Text;
                else
                    throw new Exception("not support");
                var hash = ThinNeo.Helper.GetPublicKeyHashFromAddress(str);
                return ThinNeo.Helper.GetAddressFromScriptHash(hash);
            }
            else if (type == "bytes")
            {
                var str = "";
                if ((ui is TextBlock))
                    str = (ui as TextBlock).Text;
                else if ((ui is TextBox))
                    str = (ui as TextBox).Text;
                else
                    throw new Exception("not support");
                var bts = ThinNeo.Helper.HexString2Bytes(str);
                return ThinNeo.Helper.Bytes2HexString(bts);
            }
            else if (type == "url")
            {
                var str = "";
                if ((ui is TextBlock))
                    str = (ui as TextBlock).Text;
                else if ((ui is TextBox))
                    str = (ui as TextBox).Text;
                else
                    throw new Exception("not support");
                return new ThinNeo.NNSUrl(str);
            }
            else
            {
                throw new Exception("not support type");
            }
            throw new Exception("not parsed value");
        }
        void dapp_updateValuesUI()
        {
            this.listDappValue.Items.Clear();
            foreach (var v in dapp_values)
            {
                var item = new ListBoxItem();
                item.Content = v.Key + "=" + v.Value.ToString();
                if (v.Value.error)
                {
                    item.Foreground = red;
                }
                this.listDappValue.Items.Add(item);
            }
        }

        void dapp_UpdatePluginsUI()
        {
            if (!dapp_Init)
            {
                dapp_Init = true;
                this.comboDApp.SelectionChanged += (s, e) =>
                  {
                      dapp_values.Clear();
                      var plugin = (this.comboDApp.SelectedItem as ComboBoxItem).Content as DApp_SimplePlugin;
                      if (plugin != null)
                      {
                          dappfuncs.Items.Clear();
                          dappfuncs.Tag = plugin;
                          foreach (var f in plugin.funcs)
                          {
                              var tabItem = new TabItem();
                              tabItem.Header = f.name;
                              tabItem.Tag = f;
                              dappfuncs.Items.Add(tabItem);
                              dapp_UpdateFuncUI(tabItem, f);
                          }
                      }
                  };
            }
            foreach (var m in dapp_plat.plugins)
            {
                var item = new ComboBoxItem();
                item.Content = m;
                this.comboDApp.Items.Add(item);
            }
        }
        System.Windows.Media.SolidColorBrush white
        {
            get
            {
                return new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(255, 255, 255));

            }
        }
        System.Windows.Media.SolidColorBrush red
        {
            get
            {
                return new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(255, 0, 0));

            }
        }
        void dapp_UpdateFuncUI(TabItem tabitem, DApp_Func func)
        {
            var sviewer = new ScrollViewer();
            tabitem.Content = sviewer;
            var canvas = new Canvas();
            sviewer.Content = canvas;
            canvas.Background = null;

            var text = new TextBlock();
            text.Width = 500;
            text.Height = 32;
            canvas.Children.Add(text);
            Canvas.SetLeft(text, 0);
            Canvas.SetTop(text, 0);
            text.Text = func.desc;
            text.Foreground = white;

            var y = text.Height;
            foreach (var i in func.inputs)
            {
                var label = new TextBlock();
                label.Text = i.desc;
                label.Width = 200;
                label.Height = 32;
                canvas.Children.Add(label);
                Canvas.SetLeft(label, 0);
                Canvas.SetTop(label, y);

                if (i.type == "string" || i.type == "address" || i.type == "bytes" || i.type == "url")
                {
                    TextBox tbox = new TextBox();
                    tbox.Tag = i;
                    tbox.Width = 300;
                    tbox.Height = 20;
                    tbox.Text = i.value;
                    canvas.Children.Add(tbox);
                    tbox.TextChanged += dapp_FuncValue_Text_Changed;
                    Canvas.SetLeft(tbox, 200);
                    Canvas.SetTop(tbox, y);
                    y += 20;
                }
                else
                {
                    TextBlock tbox = new TextBlock();
                    tbox.Tag = i;
                    tbox.Width = 300;
                    tbox.Height = 20;
                    tbox.Text = "unknowntype:" + i.type;
                    canvas.Children.Add(tbox);
                    Canvas.SetLeft(tbox, 200);
                    Canvas.SetTop(tbox, y);
                    y += 20;
                }
            }
        }
        void dapp_FuncValue_Text_Changed(object sender, TextChangedEventArgs e)
        {
            var input = (sender as FrameworkElement).Tag as DAppFunc_Input;
            try
            {
                var value = dapp_getValue(sender as FrameworkElement, input.type);
                this.dapp_values[input.id].value = value;
                this.dapp_values[input.id].error = false;
            }
            catch (Exception err)
            {
                this.dapp_values[input.id].value = err.Message;
                this.dapp_values[input.id].error = true;
            }
            dapp_updateValuesUI();
        }
    }
}