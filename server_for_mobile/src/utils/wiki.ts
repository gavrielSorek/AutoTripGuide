export async function wikiGetImageUrl(url: string) {
    const title = getTitleFromUrl(url);
    const response = await fetch(`https://he.wikipedia.org/w/api.php?action=query&titles=${title}&prop=pageimages&format=json&pithumbsize=100`);
    const data = await response.json();
    const pages = data.query.pages;
    const page = pages[Object.keys(pages)[0]];
    if (page && page.thumbnail && page.thumbnail.source) {
        return page.thumbnail.source;
    } else {
        return '';
    }
}

function getTitleFromUrl(url: string) {
    const urlObj = new URL(url);
    const title = urlObj.pathname.split('/').pop();
    return title;
}