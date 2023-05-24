import natural, { JaroWinklerOptions } from 'natural';
import { jaro, jaroWinkler } from "jaro-winkler-typescript";
import { JAROWINKLER_THRESHOLD } from './constants';


export function isSamePlace(name1: string, name2: string): boolean {
    const normalizedName1 = name1.trim();
    const normalizedName2 = name2.trim();
    const similarity = jaroWinkler(normalizedName1, normalizedName2, { caseSensitive: false });
    const threshold = JAROWINKLER_THRESHOLD;
    return similarity >= threshold;
}

export function wordSimilarity(name1: string, name2: string): number {
    const normalizedName1 = name1.trim();
    const normalizedName2 = name2.trim();
    return jaroWinkler(normalizedName1, normalizedName2, { caseSensitive: false });
}



