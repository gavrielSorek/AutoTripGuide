import { Configuration, OpenAIApi } from "openai";
import * as dotenv from 'dotenv' // see https://github.com/motdotla/dotenv#how-do-i-use-dotenv-with-import
import { logger } from "../utils/loggerService";
dotenv.config()


const configuration = new Configuration({
  apiKey: "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", //process.env.GPT_API_KEY,
});

const openai = new OpenAIApi(configuration);


export function gptPlaceInfo(placeName: string,address: string, length: number) {
  logger.info(`GPT request for ${placeName} in ${address}`)
  return openai
    .createCompletion({
      model: "text-davinci-003",
      prompt: `I need info about ${placeName} in ${address} in ${length} words or fewer.`,
      temperature: 1,
      max_tokens: length * 2,
      top_p: 1,
      frequency_penalty: 0,
      presence_penalty: 0,
      best_of: 1,
    })
    .then((response) => {
      if (response.data.choices[0].text === "") {
        logger.error("No answer found for " + placeName);
        return undefined;
      }
      return response.data.choices[0].text?.replace(/^\s+/, "");;
    })
    .catch((error) => {
      logger.error("error in gptPlaceInfo for " + placeName );
      logger.error(error);
      return "error";
    });
}

export async function formatToLength(
  description: string,
  length: number
): Promise<string | undefined> {
  let response;
  try {
    response = await openai.createCompletion({
      model: "text-davinci-003",
      prompt: `Rewrite the following description to be no longer than ${length} characters:\n${description}`,
      temperature: 0.2,
      max_tokens: length * 2,
      top_p: 1,
      frequency_penalty: 0,
      presence_penalty: 0,
    });
    return response.data.choices[0].text;
  } catch (error) {
    return undefined;
  }
}
