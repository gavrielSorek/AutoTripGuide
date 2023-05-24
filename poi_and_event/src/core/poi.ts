var today = new Date();
var dd = String(today.getDate()).padStart(2, '0');
var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
var yyyy = today.getFullYear();

var date = dd + '/' + mm + '/' + yyyy;

export class Poi {
  constructor(
    public _id: string = "",
    public _poiName: string = "",
    public _translated: string = "",
    public _latitude: number = 0,
    public _longitude: number = 0,
    public _shortDesc: string = "",
    public _language: string = "en",
    public _audio: string = "",
    public _source: string = "",
    public _Contributor: string = "crawler",
    public _CreatedDate: string = date,
    public _ApprovedBy: string = "shirin&avi",
    public _UpdatedBy: string = "shirin&avi",
    public _LastUpdatedDate: string = date,
    public _country: string = "",
    public _Categories: string[] = [],
    public _pic: any = "",) {}
}