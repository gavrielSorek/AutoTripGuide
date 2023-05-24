import { fetchData } from "./fetchdata";
import express, { Express, Request, Response } from "express";
import { Poi } from "./core/poi";
import { PORT } from "./utils/constants";


const app: Express = express();
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.get('/', (req: Request, res: Response) => {

    let input = req.query;
    if (typeof (input.lat) !== "number" || typeof (input.lon) !== "number" || typeof (input.rad) !== "number") {
        res.status(400).send("Bad Request")
        return
    }
    //else {
    fetchData(input.lat, input.lon, input.rad).then((data: Poi) => {
        res.send(data);
    }).catch((err: Error) => {
        res.status(500).send(err.message);
    });
    //}

});

app.listen(PORT)