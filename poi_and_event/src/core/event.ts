import { getDistance } from "../utils/distance";
import { isSamePlace } from "../utils/same_place";
import { DISTANCE_THRESHOLD_NEW_EVENT } from "../utils/constants";
import { encode } from 'ngeohash';
import { GEO_SIZE } from "../utils/constants";
export class Event {
    constructor(
        public id: string = "",
        public lat: number = 0,
        public lon: number = 0,
        public name: string = "",
        public type: string = "",
        public url: string = "",
        public startDate: string = "",
        public expireAt : Date = new Date(startDate),
        public statusCode: string = "",
        public venueName: string = "",
        public language: string = "",
        public venueLocation: string = "",
        public address: string = "",
        public images: string = "",
        public description: string = "",
        public vendor: string = "",
        public geoHash: string = encode(lat, lon, GEO_SIZE),
    ) {}
}



