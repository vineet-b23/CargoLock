const express = require('express');
const multer = require('multer');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const { PinataSDK } = require("pinata");
const { spawn } = require('child_process');
const { Blob, File } = require('buffer'); 
const app = express();
const PORT = 3000;
let aiLogs = []; 

const PINATA_JWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiIwNzE5ODMwMS0zYTRlLTRmMTgtODU2Mi0yODM1NGEyZGU0MTAiLCJlbWFpbCI6InZpbmVldC5vZmZpY2lhbDEwQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJwaW5fcG9saWN5Ijp7InJlZ2lvbnMiOlt7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6IkZSQTEifSx7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6Ik5ZQzEifV0sInZlcnNpb24iOjF9LCJtZmFfZW5hYmxlZCI6ZmFsc2UsInN0YXR1cyI6IkFDVElWRSJ9LCJhdXRoZW50aWNhdGlvblR5cGUiOiJzY29wZWRLZXkiLCJzY29wZWRLZXlLZXkiOiJjMzUxMjNmNmQ2NjJkMjVmMmU4OCIsInNjb3BlZEtleVNlY3JldCI6IjU2ZTRiNzMwMWM4ODAyNTY4OGY5NzAxMzcxZDBlNjg5OTdiOGE5MGJkZjk2NDc2NjFhMGZlNDRjYTJhMjYxNGEiLCJleHAiOjE4MDQ2MDkyOTd9.QJ_b6U-erC3FtfZCIpCtP-lffURgguxOSOsYF7oW-WA";

const pinata = new PinataSDK({
    pinataJwt: PINATA_JWT,
    pinataGateway: "yellow-deep-leopon-532.mypinata.cloud"
});

app.use(cors());
app.use(express.json());

if (!fs.existsSync('uploads')) {
    fs.mkdirSync('uploads');
}
const upload = multer({ dest: 'uploads/' });
app.get('/admin/logs', (req, res) => {
    res.json(aiLogs);
});

app.post('/upload', upload.single('evidence_image'), async (req, res) => {
    console.log("📥 Image Received. Starting Web3 + AI Pipeline...");

    if (!req.file) {
        return res.status(400).json({ error: "No image file provided." });
    }

    try {
        const localPath = req.file.path;
        const fileBuffer = fs.readFileSync(localPath);
        const blob = new Blob([fileBuffer]);
        const fileObject = new File([blob], req.file.originalname, { type: req.file.mimetype });
        
        const uploadResult = await pinata.upload.public.file(fileObject);
        const ipfsUrl = `https://gateway.pinata.cloud/ipfs/${uploadResult.cid}`;
        console.log(`✅ IPFS Link: ${ipfsUrl}`);
        const python = spawn('python', ['ai_engine.py', localPath, ipfsUrl]);

        let aiOutput = "";
        let aiError = "";

        python.stdout.on('data', (data) => { aiOutput += data.toString(); });
        python.stderr.on('data', (data) => { aiError += data.toString(); });

        python.on('close', (code) => {
            if (code !== 0) {
                return res.status(500).json({ error: "AI Script Error", details: aiError });
            }

            try {
                const cleanOutput = aiOutput.trim();
                const parsed = JSON.parse(cleanOutput);

                const finalResponse = {
                    result: parsed.result || "Not Detected",
                    summary: parsed.summary || "No description available.",
                    confidence: parsed.confidence || 0,
                    status: parsed.status || "PROCESSED",
                    ipfs_url: ipfsUrl
                };
                aiLogs.unshift({
                    id: `TRK-${Math.floor(1000 + Math.random() * 9000)}`,
                    type: finalResponse.result,
                    conf: finalResponse.confidence,
                    status: finalResponse.status,
                    time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
                    ipfs: ipfsUrl
                });

                console.log("✅ Sending to Flutter:", finalResponse);
                res.status(200).json(finalResponse);

            } catch (e) {
                res.status(500).json({ error: "AI Format Error", raw: aiOutput });
            }
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`
    -------------------------------------------
     CargoLock Backend Active
     Server: http://172.16.44.245:${PORT}
    -------------------------------------------
    `);
});