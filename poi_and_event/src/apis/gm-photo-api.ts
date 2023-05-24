import axios from 'axios';


async function fetchGoogleMapsPhoto(photoReference: string, height: number, apiKey: string): Promise<string> {
  const url = `https://maps.googleapis.com/maps/api/place/photo?maxheight=${height}&photoreference=${photoReference}&key=${apiKey}`;
  const response = await axios.get(url);
  const blob = response.data;
  return blob;
}

async function fetchGoogleMapsPhotoUrl(photoReference: string, width: number, apiKey: string): Promise<string> {
  const response = await axios.get(`https://maps.googleapis.com/maps/api/place/photo`, {
    params: {
      photoreference: photoReference,
      maxwidth: width,
      key: apiKey,
    },
  });
  return response.request.res.responseUrl;
}