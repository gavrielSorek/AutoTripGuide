export function getPoiCategory(category: string): string {
    switch (category) {
        case "shopping_mall":
            return "Malls";
        case "casino":
            return "Casino";
        case "park":
            return "Parks";
        case "restaurant":
        case "food":
        case "cafe":
        case "meal_takeaway":
            return "Restaurants";
        case "establishment":
        case "lodging":
        case "campground":
            return "Resorts";
        case "natural_feature":
            return "Nature reserves";
        case "bicycle_store":
        case "book_store":
        case "car_rental":
        case "movie_rental":
        case "home_goods_store":
        case "spa":
        case "travel_agency":
            return "Marketplaces";
        case "church":
            return "Churches";
        case "museum":
        case "art_gallery":
            return "Museums";
        case "movie_theater":
        case "stadium":
            return "Theaters";
        case "synagogue":
            return "Synagogues";
        case "aquarium":
        case "zoo":
            return "Geological formations";
        case "airport":
        case "political":
        case "university":
        case "library":
        case "city_hall":
            return "Buildings";
        case "place_of_worship":
        case "hindu_temple":
        case "cemetery":
            return "Historic architecture";

        // Interesting but there isn't suitable category
        // case "point_of_interest":
        // case "tourist_attraction":
        // case "bar":
        // case "night_club":
        // case "bowling_alley":
        //     return "1";

        // // Not interesting
        // default:
        //     return "-1";

        default:
            return "1";
    }
}



// *****Categories:
// ***found:
// Malls
// Casino
// Parks
// Restaurants
// Resorts
// Nature reserves
// Marketplaces
// Churches
// Museums
// Theaters
// Synagogues
// Geological formations
// Buildings
// Historic architecture

// ***not found:
// Rivers
// Lakes
// Diving
// Beaches
// Waterfalls
// Lagoons
// Cathedrals
// Bridges
// Archaeology
// Islands
// Pools
// Towers
// Climbing
// Picnic sites
// Surfing