const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require("./permissions.json");

admin.initializeApp({
	credential: admin.credential.cert(serviceAccount),
	databaseURL: "https://xamadukan.firebaseio.com"
});

const express = require("express");
const app = express();
const db = admin.firestore();
const cors = require("cors");
app.use( cors( { origin:true } ) );

//Routes

//Create  -Post
//This will be for history every times create new
app.post('/api/create',(req,res)=>{

	(async () => {
		db.settings({
			timestampsInSnapshots: true
		});

		const docId = new Date();

		const docName=req.body.patient.toString();
		try {
			await db.collection('Patients').doc(docName).collection('history').doc('/' + docId.getTime() + '/')
			.create({
				bpm: req.body.bpm.toString(),
				spo: req.body.spo.toString(),
				tempc: req.body.tempc.toString(),
				tempf: req.body.tempf.toString(),
				ecg: req.body.ecg.toString(),
				createdAt: new Date(),
				updatedAt: docId.getTime()
			});

		}
		catch (error) {

			return res.status(500).send(error.toString());
		}
		try{
			if (parseInt(req.body.bpm.toString())<60 || parseInt(req.body.bpm.toString())>100) {

				sendMessage(docName,"BPM",req.body.bpm.toString(),"critical");
			}
			if (parseInt(req.body.spo.toString())<75 || parseInt(req.body.spo.toString())>100) {
	//below 60 very low
	//above 120 very high

	sendMessage(docName,"SpO2",req.body.spo.toString(),"critical");
}
if (parseInt(req.body.tempf.toString())>99) {
	

	sendMessage(docName,"Temperature F",req.body.tempf.toString(),"critical");
}




}
catch (error) {

	return res.status(500).send(error.toString());
}
})();
	//return res.status(200).send('Hello-world');
});

//Update  -Put
app.put('/api/update/:id',(req,res)=>{

	(async () => {
		
		const docName=req.body.patient.toString();
		try{
			const documentx= db.collection('Patients').doc(docName).collection('results').doc("one");
			//const documentx  db.collection('results').doc(req.params.id);

			await documentx.update({
				bpm:req.body.bpm.toString(),
				spo:req.body.spo.toString(),
				tempc:req.body.tempc.toString(),
				tempf:req.body.tempf.toString(),
				ecg:req.body.ecg.toString(),
				updatedAt: new Date()
			});
			return res.status(200).send('Success');
		}
		catch (error)
		{

			return res.status(500).send(error.toString());
		}
	})();
	//return res.status(200).send('Hello-world');
});

function sendMessage(topiX,typeX,valX,statX) {

	

// const message = {
//   data: {
//     type: '$type',
//     value: '$value',
//     status:'$status'
//   },
//   topic: '$topic'
// };

const message = {
  // notification: {
  //   title: typeX,
  //   body: valX,
  // },
  data:{
  	title: typeX,
  	body: valX,
  },
  topic: topiX
};

// Send a message to devices subscribed to the provided topic.
admin.messaging().send(message)
.then((response) => {
    // Response is a message ID string.
    console.log('Successfully sent message:', response);
    return res.status(200).send('Success');
})
.catch((error) => {
	console.log('Error sending message:', error);
});
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Read  -Get
// Specific Document

app.get('/api/read/:id',(req,res)=>{


	//return res.status(200).send(req.params.id);
	(async () => {
		

		try{

			const docx=db.collection('results').doc(req.params.id);
			let result= await docx.get();
			let response=result.data();

			return res.status(200).send(response);
		}
		catch (error)
		{

			return res.status(500).send(error.toString());
		}
	})();
	//return res.status(200).send('Hello-world');
});



// All Document

app.get('/api/read/',(req,res)=>{


	//return res.status(200).send(req.params.id);
	(async () => {
		

		try{

			let query = db.collection('results');
			let response=[];


			await query.get().then(querySnapshot => {

				let docs=querySnapshot.docs;

				for(let doc of docs){

					const seletedItem={
						name:doc.data().name,
						desc:doc.data().desc,
						price:doc.data().price,
						createdAt:doc.data().createdAt,
						updatedAt:doc.data().updatedAt
					};

					response.push(seletedItem);
				}
				return response;

			});

			return res.status(200).send(response);
		}
		catch (error)
		{

			return res.status(500).send(error.toString());
		}
	})();
	//return res.status(200).send('Hello-world');
});



//Delete  -Delete
app.delete('/api/delete/:id',(req,res)=>{

	(async () => {
		

		try{
		//	const documentx = db.collection('Patients').doc('patient_test').collection('results').doc(req.params.id);
		const documentx = db.collection('results').doc(req.params.id);

		await documentx.delete();
		return res.status(200).send('Success');
	}
	catch (error)
	{

		return res.status(500).send(error.toString());
	}
})();
	//return res.status(200).send('Hello-world');
});



exports.app=functions.https.onRequest(app);
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
