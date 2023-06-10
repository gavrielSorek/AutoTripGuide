export interface Coordinate {
  lat: number;
  lng: number;
}

export interface GeoBounds {
  southWest: Coordinate;
  northEast: Coordinate;
}
