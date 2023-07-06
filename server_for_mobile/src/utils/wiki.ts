import axios from 'axios';
import { logger } from './loggerService';

export async function wikiGetImageUrl(url: string) {
    try {
        logger.info(`searching for image in wikipedia for url: ${url}`);
        const title = getTitleFromUrl(url);
        const response = await axios.get(`https://he.wikipedia.org/w/api.php?action=query&titles=${title}&prop=pageimages&format=json&pithumbsize=100`);
        const data = response.data;
        const pages = data.query.pages;
        const page = pages[Object.keys(pages)[0]];
        if (page && page.thumbnail && page.thumbnail.source) {
            return page.thumbnail.source;
        } else {
            return '';
        }
    } catch (error) {
        logger.error(`error in wikiGetImageUrl: ${error}`);
        return '';
    }
}

function getTitleFromUrl(url: string) {
    const urlObj = new URL(url);
    const title = urlObj.pathname.split('/').pop();
    return title;
}