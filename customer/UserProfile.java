package com.thekey.entity.customer;

/**
 * 用户信息
 * @author ning.fu
 *
 */
public class UserProfile {
	private int    uid;
	private String firstname;
	private String lastname;
	private String nationality_full_name;
	private String passport_number;
	private String phone;
	private String neo_wallet_address;
	private String scanned_Passport_big;//原图
	private String selfie_with_Passport_big;
	private int    status;//订单状态 1为失败，4为已收到，9为已通过
	
	
	public String getNationality_full_name() {
		return nationality_full_name;
	}
	public void setNationality_full_name(String nationality_full_name) {
		this.nationality_full_name = nationality_full_name;
	}
	public String getScanned_Passport_big() {
		return scanned_Passport_big;
	}
	public void setScanned_Passport_big(String scanned_Passport_big) {
		this.scanned_Passport_big = scanned_Passport_big;
	}
	public String getSelfie_with_Passport_big() {
		return selfie_with_Passport_big;
	}
	public void setSelfie_with_Passport_big(String selfie_with_Passport_big) {
		this.selfie_with_Passport_big = selfie_with_Passport_big;
	}
	public int getUid() {
		return uid;
	}
	public void setUid(int uid) {
		this.uid = uid;
	}
	public String getFirstname() {
		return firstname;
	}
	public void setFirstname(String firstname) {
		this.firstname = firstname;
	}
	public String getLastname() {
		return lastname;
	}
	public void setLastname(String lastname) {
		this.lastname = lastname;
	}
	public String getPassport_number() {
		return passport_number;
	}
	public void setPassport_number(String passport_number) {
		this.passport_number = passport_number;
	}
	public String getPhone() {
		return phone;
	}
	public void setPhone(String phone) {
		this.phone = phone;
	}
	public String getNeo_wallet_address() {
		return neo_wallet_address;
	}
	public void setNeo_wallet_address(String neo_wallet_address) {
		this.neo_wallet_address = neo_wallet_address;
	}
	public int getStatus() {
		return status;
	}
	public void setStatus(int status) {
		this.status = status;
	}
	
}
