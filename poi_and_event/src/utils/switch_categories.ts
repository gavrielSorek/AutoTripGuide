interface CategoryMap {
    [key: string]: string;
}

const categoryMap: CategoryMap = {
    shopping_mall: "Malls",
    park: "Parks",
    restaurant: "Restaurants",
    food: "Restaurants",
    cafe: "Restaurants",
    meal_takeaway: "Restaurants",
    establishment: "Resorts",
    lodging: "Resorts",
    campground: "Resorts",
    natural_feature: "Nature reserves",
    movie_theater: "Theaters",
    stadium: "Theaters",
    church: "Churches",
    museum: "Museums",
    art_gallery: "Museums",
    synagogue: "Synagogues",
    aquarium: "Geological formations",
    zoo: "Geological formations",
    airport: "Buildings",
    political: "Buildings",
    university: "Buildings",
    library: "Buildings",
    city_hall: "Buildings",
    place_of_worship: "Historic architecture",
    hindu_temple: "Historic architecture",
    cemetery: "Historic architecture",
};

export function getPoiCategory(category: string): string {
    const label = categoryMap[category];
    return label || "1";
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


// AT categories:

// "Buildings"
// "Ancient buildings"
// "Agricultural buildings"

// "Parks"
// "National parks"
// "Gardens"
// "Zoos"

// "Museums"
// "Ethnic museums"
// "History museums"
// "Railway museums"
// "National museums"
// "Literary museums"
// "Art museums"
// "Archaeological museums"
// "Science museums"

// "Towers"
// "Bridges"
// "Historic architecture"
// "Casino"
// "Resorts"
// "Theaters"
// "Archaeology"
// "Beaches"
// "Geological formations"
// "Islands"
// "Nature reserves"
// "Rivers"
// "Waterfalls"
// "Lagoons"
// "Lakes"
// "Synagogues"
// "Cathedrals"
// "Churches"
// "Pools"
// "Climbing"
// "Diving"
// "Surfing"
// "Restaurants"
// "Picnic sites"
// "Malls"
// "Marketplaces"