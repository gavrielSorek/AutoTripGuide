import sharp, { Stats } from 'sharp';
import fs from 'fs';
import path from 'path';



async function calculateClarity(image: sharp.Sharp): Promise<number> {
    // resizes the image to a smaller size
    const resized_image = await image.resize({ width: 100 }).grayscale().toBuffer();
    // gets the grayscale values of all the pixels in the resized image
    const pixels = await image.resize({ width: 100 }).toBuffer({ resolveWithObject: true }).then(result => result.data);
    // calculates the average grayscale value
    const total_grayscale = pixels.reduce((sum, value) => sum + value, 0);
    const average_grayscale = total_grayscale / pixels.length;
    const clarity = Math.round(average_grayscale / 25)
    // normalize
    return clarity > 1 ? clarity +  3: clarity;

    //return clarity_stats.isOpaque == true ? 1: 0 
}

  
async function calculateSharpness(image: sharp.Sharp): Promise<number> {
    const sharpness_buffer = await image
        .greyscale() // converts the image to grayscale
        .flatten() // removes any alpha channel
        .sharpen()
        .toBuffer();
    const sharpness_stats = await sharp(sharpness_buffer).stats(); //stats computes the image statistics
    // +1 for values between 1 to 10
    return Math.round(sharpness_stats.sharpness) + 1;
}


async function calculateInterestingness(image: sharp.Sharp): Promise<number> {
    const stats = await image.stats();
    // the amount of information in the image
    return stats.entropy;
}


export async function getPictureRate(image_path: string): Promise<[number, number, number, number] | undefined> {
    try {
        const image = sharp(image_path);
        const clarity_score = await calculateClarity(image);
        const sharpness_score = await calculateSharpness(image);
        const interestingness_score = await calculateInterestingness(image);
        const overall_rate = Math.round((clarity_score + interestingness_score + sharpness_score) / 3);

        // return a number between 1 to 10 for each parameter
        return [clarity_score, sharpness_score, interestingness_score, overall_rate];

    } catch (error) {
        // Handle any errors or exceptions that may occur
        return undefined;
    }
}



// async function testPictures() {
//     const path = 'C:/Users/bazis/OneDrive/Pictures/whatsapp/'
//     for (let i = 1; i <= 10; i++) {
//         console.log('##### PICTURE ' + i)
//         await getPictureRate(`${path}${i}.jpg`).then((result) => {
//             if (result !== undefined) {
//                 const [clarity, sharpness, interestingness, overallRate] = result
//                 console.log(`Clarity: ${clarity}, Sharpness: ${sharpness}, Interestingness: ${interestingness}, OverallRate: ${overallRate}\n`);
//             } else {
//                 console.log('Error');
//             }
//         });
    

async function testPictures(images: string[]) {
    const promises = images.map(getPictureRate);
    const results = await Promise.all(promises);
    for (const [i, result] of results.entries()) {
        console.log("image number: " + i);
        if (result !== undefined) {
            const [clarity, sharpness, interestingness, overallRate] = result;
            console.log(`Clarity: ${clarity}, Sharpness: ${sharpness}, Interestingness: ${interestingness}, OverallRate: ${overallRate}\n`);
        } else {
            console.log('Error');
        }
    }
}

function getImagesFromPath(directoryPath: string): string[] {
    const imageExtensions = ['.jpg', '.jpeg', '.png'];
    const files = fs.readdirSync(directoryPath);
    const imageFiles = files.filter((file) =>
      imageExtensions.includes(path.extname(file))
    );
    return imageFiles.map((file) => path.join(directoryPath, file));
  }




let images : string[] = getImagesFromPath("D:\\Program Files\\תמונות")

const start = Date.now();
testPictures(images).then(() => {
    const end = Date.now();
    console.log(`Execution time: ${end - start} ms`);
});
