import axios from "axios";
import { INTEREST_VALUE_URL } from "../utils/constants";


export async function getInterestValue(poiName: string, description: string) {
  try {
    const { data, status } = await axios.post(
      INTEREST_VALUE_URL,
      { poiName: poiName, description: description },
      {
        headers: {
          Accept: 'application/json',
        },
      },
    );
    return data;
  } catch (error) {
    if (axios.isAxiosError(error)) {
      return error.message;
    } else {
      return 'An unexpected error occurred';
    }
  }
};