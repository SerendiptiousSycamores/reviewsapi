require('dotenv').config();
const express = require('express');
const morgan = require('morgan');
const db = require('./db');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(morgan('dev'));
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

app.get('/', async (req, res) => {
  const { product_id, sort } = req.query;
  const page = req.query.page || 1;
  const count = req.query.count || 5;
  const offset = (page - 1) * count;
  let results;

  try {
    if (sort === 'helpful') {
      results = await db.query(
        "SELECT id::INT AS review_id, rating, summary, recommend, response, body, date, reviewer_name, helpfulness, COALESCE((SELECT json_agg(nested_photo) FROM (SELECT id, url FROM photos WHERE review_id = reviews.id) AS nested_photo), '[]') AS photos FROM reviews WHERE product_id = $1 AND reported = false ORDER BY helpfulness DESC OFFSET $2 LIMIT $3;",
        [product_id, offset, count]);
    } else if (sort === 'newest') {
      results = await db.query(
        "SELECT id::INT AS review_id, rating, summary, recommend, response, body, date, reviewer_name, helpfulness, COALESCE((SELECT json_agg(nested_photo) FROM (SELECT id, url FROM photos WHERE review_id = reviews.id) AS nested_photo), '[]') AS photos FROM reviews WHERE product_id = $1 AND reported = false ORDER BY date DESC OFFSET $2 LIMIT $3;",
        [product_id, offset, count]);
    } else if (sort === 'relevant') {
      results = await db.query(
        "SELECT id::INT AS review_id, rating, summary, recommend, response, body, date, reviewer_name, helpfulness, COALESCE((SELECT json_agg(nested_photo) FROM (SELECT id, url FROM photos WHERE review_id = reviews.id) AS nested_photo), '[]') AS photos FROM reviews WHERE product_id = $1 AND reported = false ORDER BY helpfulness DESC, date DESC OFFSET $2 LIMIT $3;",
        [product_id, offset, count]);
    }
    res.status(200).json({
      product: product_id,
      page,
      count: results.rows.length,
      results: results.rows
    });
  } catch (err) {
    res.sendStatus(404);
  }
});

// method: get
// endpoint: /reviews/meta
// req structure: query param: product_id(int)
// res structure: {
//   "product_id": INT,
//   "ratings": {
//     2: INT,
//     // ...
//   },
//   "recommended": {
//     0: INT
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
app.get('/meta', async (req, res) => {
  const { product_id } = req.query;
  try {
    const ratingsRec = await db.query('SELECT (SELECT json_object(rating, count) AS rating FROM (SELECT array_agg(rating) AS rating, array_agg(count) AS count FROM (SELECT rating::text, COUNT(rating)::text AS count FROM reviews WHERE product_id = $1 AND reported = false GROUP BY rating ORDER BY rating ASC) AS ratings) AS result) AS ratings, (SELECT json_object(recommend, count) AS recommended FROM (SELECT array_agg(recommend) AS recommend, array_agg(count) AS count FROM (SELECT recommend::int::text, COUNT(recommend)::text AS count FROM reviews WHERE product_id = $1 AND reported = false GROUP BY recommend ORDER BY recommend ASC) AS recommended) AS result) AS recommended;', [product_id]);

    const characteristicsArr = await db.query('SELECT c.name AS name , (SELECT ROW_TO_JSON(values) FROM (SELECT cr.characteristic_id AS id, AVG(cr.value)::numeric(10, 4)::text AS value) AS values) AS value FROM characteristic_review cr INNER JOIN characteristics c ON cr.characteristic_id = c.id WHERE c.product_id = $1 GROUP BY cr.characteristic_id, c.name ORDER BY cr.characteristic_id ASC;', [product_id])

    const { ratings, recommended } = ratingsRec.rows[0];
    const characteristics = {};

    characteristicsArr.rows.forEach((chararateristic) => {
      const { name, value } = chararateristic;
      characteristics[name] = value;
    })

    const meta = {
      product_id,
      ratings,
      recommended,
      characteristics
    }

    res.status(200).json(meta);
  } catch (err) {
    res.sendStatus(404);
  }
});

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
app.post('/', async (req, res) => {
  const { product_id, rating, summary, body, recommend, name, email, photos, characteristics } = req.body;
  try {
    const result = await db.query('INSERT INTO reviews3(product_id, rating, summary, body, recommend, reviewer_name, reviewer_email) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *;', [product_id, rating, summary, body, recommend, name, email]);
    const review_id = result.rows[0].id;
    const insertPhoto = photos.forEach(async (url) => {
      const insert = await db.query('INSERT INTO photos3(review_id, url) VALUES ($1, $2) RETURNING *', [review_id, url])
    });
    const characteristic_id = Object.keys(characteristics);
    const insertCharacteristic = characteristic_id.forEach(async (id) => {
      const insert = await db.query('INSERT INTO characteristic_review3(characteristic_id, review_id, value) VALUES ($1, $2, $3) RETURNING *', [id, review_id, characteristics[id]]);
    });
    res.sendStatus(201);
  } catch(err) {
    res.sendStatus(404);
  }
});

// method: put
// endpoint: /reviews/:review_id/helpful
// req structure: query param: review_id(int)
// res structure: Status: 204 NO CONTENT
app.put('/:review_id/helpful', async (req, res) => {
  const { review_id } = req.params;
  try {
    const results = await db.query('UPDATE reviews SET helpfulness = (helpfulness + 1) WHERE id = $1', [review_id]);
    res.sendStatus(204);
  } catch (err) {
    res.sendStatus(404);
  }
});

// method: put
// endpoint: /reviews/:review_id/report
// req structure: query param: review_id(int)
// res structure: Status: 204 NO CONTENT
app.put('/:review_id/report', async (req, res) => {
  const { review_id } = req.params;
  try {
    const results = await db.query('UPDATE reviews SET reported = true WHERE id = $1', [review_id]);
    res.sendStatus(204);
  } catch (err) {
    res.sendStatus(404);
  }
});

app.listen(PORT, () => {
  console.log(`Listening in on port ${PORT}`)
});