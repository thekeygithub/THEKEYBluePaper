package com.thekey.entity.customer;

import java.math.BigDecimal;

/**
 * 历史订单表
 * @author ning.fu
 *
 */
public class OrderHistory {
	private  int  id;
	private  int  uid;
	private  String  currency;
	private  BigDecimal  amount;
	private  BigDecimal  rate_btc;//购买所使用的币种兑BTC的汇率，如果用户直接使用BTC购买，这里则为1
	private  BigDecimal  rate_tky;//用户购买时，BTC兑TKY的汇率
	private  BigDecimal  rate_usd;
	private  BigDecimal  usd_cny;
	private  String  investment_address;
	private  String  token_money_address;//用户付款时所用的钱包地址
	private  BigDecimal  amount_tky;//用户所应购买到的TKY总数
	private  BigDecimal  amount_btc;//用户所付代币换算为BTC后的数量，如果用户支付的是BTC，这个值则等于amount字段的值
	private  BigDecimal  amount_cny;
	private  BigDecimal  discount;//用户下单时TKY的折扣
	private  int  status;//订单状态。0为已取消，1为已下单，4为已支付，7为已经支付TKY给用户，订单完成。
	private  int  paid_at;//确认收到用户付款的时间
	private  int  updated_at;
	private  int  created_at;//交易创建时间，用户购买时间，如果超过36个小时未支付，则本次交易取消
	private  BigDecimal  received_amount;
	private  BigDecimal  amount_usd;
	private  int  order_type;//PRIVATE REPLACEMENT 1，	PRE DISTRIBUTION	2	，KYC BONUS 3	，EARLY INVESTOR BONUS 4，	REFERRAL BONUS 5，	COMMITION 6，7 DISTRIBUTION
	private  BigDecimal  lock_up;
	private  int  refundable;//是否可退，1为可退，默认为0
	private  int  refund_at;//退款时间
	private  String  refund_address;
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public int getUid() {
		return uid;
	}
	public void setUid(int uid) {
		this.uid = uid;
	}
	public String getCurrency() {
		return currency;
	}
	public void setCurrency(String currency) {
		this.currency = currency;
	}
	public BigDecimal getAmount() {
		return amount;
	}
	public void setAmount(BigDecimal amount) {
		this.amount = amount;
	}
	public BigDecimal getRate_btc() {
		return rate_btc;
	}
	public void setRate_btc(BigDecimal rate_btc) {
		this.rate_btc = rate_btc;
	}
	public BigDecimal getRate_tky() {
		return rate_tky;
	}
	public void setRate_tky(BigDecimal rate_tky) {
		this.rate_tky = rate_tky;
	}
	public BigDecimal getRate_usd() {
		return rate_usd;
	}
	public void setRate_usd(BigDecimal rate_usd) {
		this.rate_usd = rate_usd;
	}
	public BigDecimal getUsd_cny() {
		return usd_cny;
	}
	public void setUsd_cny(BigDecimal usd_cny) {
		this.usd_cny = usd_cny;
	}
	public String getInvestment_address() {
		return investment_address;
	}
	public void setInvestment_address(String investment_address) {
		this.investment_address = investment_address;
	}
	public String getToken_money_address() {
		return token_money_address;
	}
	public void setToken_money_address(String token_money_address) {
		this.token_money_address = token_money_address;
	}
	public BigDecimal getAmount_tky() {
		return amount_tky;
	}
	public void setAmount_tky(BigDecimal amount_tky) {
		this.amount_tky = amount_tky;
	}
	public BigDecimal getAmount_btc() {
		return amount_btc;
	}
	public void setAmount_btc(BigDecimal amount_btc) {
		this.amount_btc = amount_btc;
	}
	public BigDecimal getAmount_cny() {
		return amount_cny;
	}
	public void setAmount_cny(BigDecimal amount_cny) {
		this.amount_cny = amount_cny;
	}
	public BigDecimal getDiscount() {
		return discount;
	}
	public void setDiscount(BigDecimal discount) {
		this.discount = discount;
	}
	public int getStatus() {
		return status;
	}
	public void setStatus(int status) {
		this.status = status;
	}
	public int getPaid_at() {
		return paid_at;
	}
	public void setPaid_at(int paid_at) {
		this.paid_at = paid_at;
	}
	public int getUpdated_at() {
		return updated_at;
	}
	public void setUpdated_at(int updated_at) {
		this.updated_at = updated_at;
	}
	public int getCreated_at() {
		return created_at;
	}
	public void setCreated_at(int created_at) {
		this.created_at = created_at;
	}
	public BigDecimal getReceived_amount() {
		return received_amount;
	}
	public void setReceived_amount(BigDecimal received_amount) {
		this.received_amount = received_amount;
	}
	public BigDecimal getAmount_usd() {
		return amount_usd;
	}
	public void setAmount_usd(BigDecimal amount_usd) {
		this.amount_usd = amount_usd;
	}
	public int getOrder_type() {
		return order_type;
	}
	public void setOrder_type(int order_type) {
		this.order_type = order_type;
	}
	public BigDecimal getLock_up() {
		return lock_up;
	}
	public void setLock_up(BigDecimal lock_up) {
		this.lock_up = lock_up;
	}
	public int getRefundable() {
		return refundable;
	}
	public void setRefundable(int refundable) {
		this.refundable = refundable;
	}
	public int getRefund_at() {
		return refund_at;
	}
	public void setRefund_at(int refund_at) {
		this.refund_at = refund_at;
	}
	public String getRefund_address() {
		return refund_address;
	}
	public void setRefund_address(String refund_address) {
		this.refund_address = refund_address;
	}
	
}