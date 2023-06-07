import { Configuration, OpenAIApi } from "openai";
import * as dotenv from 'dotenv' // see https://github.com/motdotla/dotenv#how-do-i-use-dotenv-with-import
dotenv.config()


const configuration = new Configuration({
  apiKey: "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", //process.env.GPT_API_KEY,
});

const openai = new OpenAIApi(configuration);


export function gptPlaceInfo(placeName: string,address: string, length: number) {
  console.log('gpt request info for',placeName,address,length)
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
        console.log("No answer found");
        return undefined;
      }
      return response.data.choices[0].text?.replace(/^\s+/, "");;
    })
    .catch((error) => {
      console.log(error)
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
