import { LightningElement, wire, api, track } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import checkURLParams from "@salesforce/apex/CustomerController.checkURLParams";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import SHOESIZE from "@salesforce/schema/Customer__c.Shoe_Size__c";
import TSHIRTSIZE from "@salesforce/schema/Customer__c.TShirt_Size__c";
import updateCustomerDetails from "@salesforce/apex/CustomerController.updateCustomerDetails";

export default class AbcCustomerLWC extends LightningElement {
  urlId = "";
  urlUid = "";
  @track customer = {};
  showSizePicklistValues = [];
  tshirtSizePicklistValues = [];

  @wire(getPicklistValues, {
    recordTypeId: "0125h000001hmyxAAA",
    fieldApiName: SHOESIZE
  })
  getPicklistValuesForShoeSize({ data, error }) {
    if (error) {
      console.error(error);
    } else if (data) {
      this.showSizePicklistValues = [...data.values];
    }
  }
  @wire(getPicklistValues, {
    recordTypeId: "0125h000001hmyxAAA",
    fieldApiName: TSHIRTSIZE
  })
  getPicklistValuesForTshirtSize({ data, error }) {
    if (error) {
      console.error(error);
    } else if (data) {
      this.tshirtSizePicklistValues = [...data.values];
    }
  }
  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.urlId = currentPageReference.state?.id;
      this.urlUid = currentPageReference.state?.uid;
    }
  }

  connectedCallback() {
    checkURLParams({ urlId: this.urlId, urlUid: this.urlUid })
      .then((result) => {
        console.log(result);
        this.customer = result;
      })
      .catch((error) => {
        const event = new ShowToastEvent({
          title: "Error!",
          message: "Contact System Admin | " + error[0].message,
          variant: "error",
          mode: "dismissable"
        });
        this.dispatchEvent(event);
      });
  }
  handleSubmit(event) {}
  handleShoeSizeChange(event) {
    this.customer.Shoe_Size__c = event.target.value;
  }
  handleTShirtSize(event) {
    this.customer.TShirt_Size__c = event.target.value;
  }
  handleClick(myEvent) {
    if (this.customer.Date_of_Birth__c == null) {
      const event = new ShowToastEvent({
        title: "Error!",
        message: "Please fill your date of birth",
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(event);
      return;
    }
    if (this.customer.Phone_Number__c == null) {
      const event = new ShowToastEvent({
        title: "Error!",
        message: "Please fill your Phone Number",
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(event);
      return;
    }
    if (
      this.customer.Shoe_Size__c == null ||
      !this.customer.hasOwnProperty("Shoe_Size__c")
    ) {
      const event = new ShowToastEvent({
        title: "Error!",
        message: "Please fill your Shoe Size",
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(event);
      return;
    }
    if (
      this.customer.TShirt_Size__c == null ||
      !this.customer.hasOwnProperty("TShirt_Size__c")
    ) {
      const event = new ShowToastEvent({
        title: "Error!",
        message: "Please fill your TShirt Size",
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(event);
      return;
    }
    console.log(JSON.stringify(this.customer));

    updateCustomerDetails({
      customerData: this.customer
    })
      .then((result) => {
        const event = new ShowToastEvent({
          title: "Success!",
          message: "Record Saved Successfully",
          variant: "success",
          mode: "dismissable"
        });
        this.dispatchEvent(event);
      })
      .catch((error) => {
        var msg = error.length > 0 ? error[0].message : error.message;
        const event = new ShowToastEvent({
          title: "Error!",
          message: msg,
          variant: "error",
          mode: "dismissable"
        });
        this.dispatchEvent(event);
      });
  }
  handleDOB(event) {
    this.customer.Date_of_Birth__c = event.target.value;
  }
  handlePhone(event) {
    this.customer.Phone_Number__c = event.target.value;
  }
}