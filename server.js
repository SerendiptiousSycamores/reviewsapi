const express = require('express');

const app = express();
const PORT = 5000;

app.use(express.json());

// method: get
// endpoint: /reviews
// req structure: query param: product_id(int), page(int), count(int), sort(text)
// res structure: // {
//   "product": INT,
//   "page": INT,
//   "count": INT,
//   "results": [
//     {
//       "review_id": INT,
//       "rating": INT,
//       "summary": STRING,
//       "recommend": BOOLEAN,
//       "response": STRING (not required),
//       "body": STRING,
//       "date": DATE
//       "reviewer_name": STRING,
//       "helpfulness": INT,
//       "photos": [{
//           "id": INT,
//           "url": STRING
//         },
//         // ...
//       ]
//     },
//     // ...
//   ]
// }
app.get('/reviews');

// method: get
// endpoint: /reviews/meta
// req structure: query param: product_id(int)
// res structure: {
//   "product_id": INT,
//   "ratings": {
//     2: INT,   <-  review_id
//     // ...
//   },
//   "recommended": {
//     0: INT   <-  review_id
//     // ...
//   },
//   "characteristics": {  <- each review_id
//     "Size": {
//       "id": 14,
//       "value": INT
//     },
//     "Width": {
//       "id": 15,
//       "value": INT
//     },
//     "Comfort": {
//       "id": 16,
//       "value": INT
//     },
//     // ...
// }
app.get('/reviews/meta')

// method: post
// endpoint: /reviews
// req structure: body params:{
//   product_id: INT,
//   rating: INT,
//   summary: STRING,
//   body: STRING,
//   recommend: BOOLEAN,
//   name: STRING,
//   email: STRING,
//   photos: [STRING],
//   characteristics: {
//     "14": INT,
//     "15": INT,
//     "16": INT
//   }
// }
// res structure: Status: 201 Created
app.post('/reviews');

// method: put
// endpoint: /reviews/:review_id/helpful
// req structure: query param: review_id(int)
// res structure: Status: 204 NO CONTENT
app.put('/reviews/:review_id/helpful');

// method: put
// endpoint: /reviews/:review_id/report
// req structure: query param: review_id(int)
// res structure: Status: 204 NO CONTENT
app.put('/reviews/:review_id/report');

app.listen(PORT, () => {
  console.log(`Listening in on port ${PORT}`)
});