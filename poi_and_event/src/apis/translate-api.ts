import axios from 'axios';
import { generateRequestUrl, normaliseResponse } from 'google-translate-api-browser';
import { Poi } from '../core/poi';

export const languageMap: {[key: string]: any} = {
  'english': 'en',
  'spanish': 'es',
  'french': 'fr',
  'german': 'de',
  'italian': 'it',
  'portuguese': 'pt',
  'russian': 'ru',
  'chinese': 'zh-CN',
  'japanese': 'ja',
  'korean': 'ko',
  'hebrew': 'he',
  'arabic': 'ar',
};

export async function translate(text: string, language: string = 'en'): Promise<string | undefined> {
  const languageCode = languageMap[language.toLowerCase()] || language;
  
  try {
    const translationUrl = generateRequestUrl(text, { to: languageCode });
    const response = await axios.get(translationUrl);
    const translation = response.data;
    const normalizedTranslation = normaliseResponse(translation);
    return normalizedTranslation.text;
  } catch (e) {
    return undefined;
  }
}

export async function translateDescriptions(pois_list: Poi[], language: string): Promise<Poi[]> {
  for (let poi of pois_list) {
    let translated_description = await translate(poi._shortDesc, language)
    if (translated_description === undefined) { translated_description = poi._shortDesc }
    poi._shortDesc = translated_description
  }
  return pois_list
}

// translateDescriptions(pois, 'hebrew').then((translated_pois) => {
//   console.log("translated pois:");
// })
