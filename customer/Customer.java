package com.thekey.entity.customer;

import java.util.List;

import com.thekey.entity.referral.Referral;
/**
 * 客户信息表实体
 * @author ning.fu
 *
 */
public class Customer {
	private int id;
	private int created;
	private List<Referral> referralList;
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public int getCreated() {
		return created;
	}
	public void setCreated(int created) {
		this.created = created;
	}
	public List<Referral> getReferralList() {
		return referralList;
	}
	public void setReferralList(List<Referral> referralList) {
		this.referralList = referralList;
	}
	
}
