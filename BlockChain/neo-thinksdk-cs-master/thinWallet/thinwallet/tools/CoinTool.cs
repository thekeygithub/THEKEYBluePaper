﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace thinWallet.Tools
{
    public class Nep5Info
    {
        public string name;
        public string symbol;
        public int decimals;
    }
    public class TranInfo
    {
        public string txid;
        public ThinNeo.TransactionType type;
        public DateTime time;
    }

    public class CoinTool
    {
        //资产名字表
        public static Dictionary<string, string> assetUTXO = new Dictionary<string, string>();
        public static Dictionary<string, Nep5Info> assetNep5 = new Dictionary<string, Nep5Info>();
        public static string GetName(string assetID)
        {
            if (assetUTXO.ContainsKey(assetID))
                return assetUTXO[assetID];
            else if (assetNep5.ContainsKey(assetID))
                return assetNep5[assetID].symbol;
            else
                return assetID;
        }
        public const string id_GAS = "0x602c79718b16e442de58778e148d0b1084e3b2dffd5de6b7b16cee7969282de7";
        public const string id_NEO = "0xc56f33fc6ecfcd0c225c4ab356fee59390af8560be0e930faebe74a6daff7c9b";
        public static void ParseUtxoAsset(MyJson.JsonNode_Array json)
        {

            foreach (var asset in json)
            {
                var id = asset.AsDict()["id"].AsString();
                if (id == "0xc56f33fc6ecfcd0c225c4ab356fee59390af8560be0e930faebe74a6daff7c9b")
                {
                    assetUTXO[id] = "NEO";
                    continue;
                }
                else if (id == "0x602c79718b16e442de58778e148d0b1084e3b2dffd5de6b7b16cee7969282de7")
                {
                    assetUTXO[id] = "GAS";
                    continue;
                }
                var type = asset.AsDict()["type"];
                var name = asset.AsDict()["name"].AsList();

                string rname = null;
                foreach (var nameitem in name)
                {
                    var lang = nameitem.AsDict()["lang"].AsString();
                    var _name = nameitem.AsDict()["name"].AsString();
                    if (rname == null)
                        rname = _name;

                    if (lang == "zh-CN")
                    {
                        rname = _name;
                    }
                    else if (lang == "en")
                    {
                        rname = _name;
                        break;
                    }
                }
                assetUTXO[id] = rname;
            }
        }
        public static List<TranInfo> TxHistory = new List<TranInfo>();
        public static List<string> UtxoHistory = new List<string>();
        public static string RecordTran(ThinNeo.Transaction trans)
        {
            var txid = trans.GetHash().ToString();
            TranInfo info = new TranInfo();
            info.time = DateTime.Now;
            info.type = trans.type;
            info.txid = txid;
            TxHistory.Add(info);
            foreach (var input in trans.inputs)
            {
                var txid2 = ThinNeo.Helper.Bytes2HexString(input.hash.Reverse().ToArray());
                var strutxo = txid2 + "_" + input.index;
                UtxoHistory.Add(strutxo);
            }
            return txid;
        }
        public static void SaveNep5()
        {
            MyJson.JsonNode_Object mapInfo = new MyJson.JsonNode_Object();
            foreach (var item in assetNep5)
            {
                MyJson.JsonNode_Object jsonItem = new MyJson.JsonNode_Object();
                mapInfo[item.Key] = jsonItem;
                jsonItem["name"] = new MyJson.JsonNode_ValueString(item.Value.name);
                jsonItem["symbol"] = new MyJson.JsonNode_ValueString(item.Value.symbol);
                jsonItem["decimals"] = new MyJson.JsonNode_ValueNumber(item.Value.decimals);
            }
            System.IO.File.Delete("nep5config.json");
            System.IO.File.WriteAllText("nep5config.json", mapInfo.ToString(), System.Text.Encoding.UTF8);
        }
        public static void SaveRecord()
        {
            MyJson.JsonNode_Array traninfo = new MyJson.JsonNode_Array();
            foreach (var item in TxHistory)
            {
                MyJson.JsonNode_Object jsonItem = new MyJson.JsonNode_Object();
                traninfo.Add(jsonItem);
                jsonItem["txid"] = new MyJson.JsonNode_ValueString(item.txid);
                jsonItem["type"] = new MyJson.JsonNode_ValueString(item.type.ToString());
                jsonItem["time"] = new MyJson.JsonNode_ValueString("utc_" + item.time.ToFileTimeUtc());
            }
            MyJson.JsonNode_Array utxospentinfos = new MyJson.JsonNode_Array();

            foreach (var item in UtxoHistory)
            {
                MyJson.JsonNode_ValueString jsonItem = new MyJson.JsonNode_ValueString(item);
                utxospentinfos.Add(jsonItem);
            }
            MyJson.JsonNode_Object record = new MyJson.JsonNode_Object();
            record["trans"] = traninfo;
            record["utxos"] = utxospentinfos;

            System.IO.File.Delete("records.json");
            System.IO.File.WriteAllText("records.json", record.ToString(), System.Text.Encoding.UTF8);

        }
        public static void LoadNep5()
        {
            try
            {
                var str = System.IO.File.ReadAllText("nep5config.json", System.Text.Encoding.UTF8);
                var mapInfo = MyJson.Parse(str).AsDict();
                foreach (var item in mapInfo)
                {
                    var newitem = new Nep5Info();
                    assetNep5[item.Key] = newitem;
                    newitem.name = item.Value.AsDict()["name"].AsString();
                    newitem.symbol = item.Value.AsDict()["symbol"].AsString();
                    newitem.decimals = item.Value.AsDict()["decimals"].AsInt();
                }
            }
            catch
            {

            }
        }
        public static void LoadRecord()
        {
            try
            {
                TxHistory.Clear();
                UtxoHistory.Clear();
                var str = System.IO.File.ReadAllText("records.json", System.Text.Encoding.UTF8);
                var record = MyJson.Parse(str).AsDict();
                foreach (var item in record["trans"].AsList())
                {

                    var newitem = new TranInfo();
                    TxHistory.Add(newitem);
                    newitem.txid = item.AsDict()["txid"].AsString();
                    newitem.type = (ThinNeo.TransactionType)Enum.Parse(typeof(ThinNeo.TransactionType), item.AsDict()["type"].AsString());
                    newitem.time = DateTime.FromFileTimeUtc(long.Parse(item.AsDict()["time"].AsString().Substring(4)));
                }
                foreach (var item in record["uxtos"].AsList())
                {
                    UtxoHistory.Add(item.AsString());
                }
            }
            catch
            {

            }
        }
        public static void Load()
        {
            LoadNep5();
            LoadRecord();
        }
    }
    public class Asset
    {
        public List<CoinType> allcoins = new List<CoinType>();
        public void ParseUTXO(MyJson.JsonNode_Array jsonarray)
        {
            Dictionary<string, CoinType> cointype = new Dictionary<string, CoinType>();
            foreach (var item in jsonarray)
            {
                var asset = item.AsDict()["asset"].AsString();
                if (cointype.ContainsKey(asset) == false)
                {
                    var ctype = new CoinType(asset);
                    cointype[asset] = ctype;
                    allcoins.Add(ctype);
                }
                var coins = cointype[asset];
                var coin = new UTXOCoin();
                coin.assetID = asset;
                coin.fromID = item.AsDict()["txid"].AsString();
                coin.fromN = item.AsDict()["n"].AsInt();
                var value = decimal.Parse(item.AsDict()["value"].AsString());
                coin.value = value;
                coins.coins.Add(coin);

            }
        }

    }
    public class Input
    {
        public UTXOCoin Coin;//币
        public byte[] From;//来源，需要这个人或者脚本做witness
        public byte[] Script;//脚本，可以為null
        public string Address
        {
            get
            {
                return ThinNeo.Helper.GetAddressFromScriptHash(From);
            }
        }
        public override string ToString()
        {
            return Coin.ToString();
        }
    }

    public class Output
    {
        public bool isTheChange = false;//是否是找零
        public string Target;//接收者
        public string assetID;
        public ThinNeo.Fixed8 Fix8;//fix8 number
        public override string ToString()
        {
            if (string.IsNullOrEmpty(this.Target))
            {
                return "(Drop:" + CoinTool.GetName(assetID) + ")" + Fix8.ToString() ;
            }
            return (isTheChange ? "(ChangeBack:" : "(") + CoinTool.GetName(assetID) + ")" + Fix8.ToString() + " ==>" + Target;
        }
    }


    public class UTXOCoin
    {
        public string fromID;
        public int fromN;
        public string assetID;
        public decimal value;
        public override string ToString()
        {
            return "(" + CoinTool.GetName(assetID) + ")" + value + " <==" + fromID.Substring(0, 6) + "...." + fromID.Substring(fromID.Length - 4) + "[" + fromN + "]";
        }
        public UTXOCoin Clone()
        {
            UTXOCoin coin = new UTXOCoin();
            coin.fromID = this.fromID;
            coin.fromN = this.fromN;
            coin.assetID = this.assetID;
            coin.value = this.value;
            return coin;
        }
    }

    public class CoinType
    {
        //for utxo
        public string AssetID
        {
            get;
            private set;
        }
        public bool NEP5
        {
            get;
            private set;
        }
        public List<UTXOCoin> coins = new List<UTXOCoin>();

        decimal _valueNep5;
        public decimal Value
        {
            get
            {
                if (NEP5)
                {
                    return _valueNep5;
                }
                else
                {
                    decimal value = 0;
                    foreach (var c in coins)
                    {
                        value += c.value;
                    }
                    return value;
                }
            }
            set
            {
                if (NEP5)
                    _valueNep5 = value;
            }
        }


        public CoinType(string AssetID, bool nep5 = false)
        {
            this.AssetID = AssetID;
            this.NEP5 = nep5;
        }
    }
}
