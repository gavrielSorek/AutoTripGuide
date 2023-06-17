import { Sources } from "./sources";

var today = new Date();
var dd = String(today.getDate()).padStart(2, '0');
var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
var yyyy = today.getFullYear();

var date = dd + '/' + mm + '/' + yyyy;
export const blacklistStrings: string[] = ['depopulated','palestinian'];

export interface vendorInfo {
  _source: Sources,
  _placeId: string,
  // for google
  _avgRating?: number,
  _numReviews?: number,
  _rating?: string,
  _plus_code?: string,
  // for open trip
  _url?: string,
  _wikiPlaceId?: string,
}
export class Poi {
  constructor(
    // public _id: string = "",
    public _poiName: string = "",
    public _latitude: number = 0,
    public _longitude: number = 0,
    public _shortDesc: string = "",
    public _language: string = "en",
    public _vendorInfo: vendorInfo| null = null,
    public _audio: string = "",
    public _source: string = "",
    public _Contributor: string = "crawler",
    public _CreatedDate: string = date,
    public _ApprovedBy: string = "shirin&avi",
    public _UpdatedBy: string = "shirin&avi",
    public _LastUpdatedDate: string = date,
    public _country: string = "",
    public _Categories: string[] = [],
    public _pic: any = "") {
      // this._id = _id;
      this._poiName = _poiName;
      this._latitude = _latitude;
      this._longitude = _longitude;
      this._shortDesc = _shortDesc;
      this._language = _language;
      this._audio = _audio;
      this._source = _source;
      this._Contributor = _Contributor;
      this._CreatedDate = _CreatedDate;
      this._ApprovedBy = _ApprovedBy;
      this._UpdatedBy = _UpdatedBy;
      this._LastUpdatedDate = _LastUpdatedDate;
      this._country = _country;
      this._Categories = _Categories;
      this._pic = _pic;
      this._vendorInfo = _vendorInfo;
  }
}