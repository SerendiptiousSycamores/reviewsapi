-- id,product_id,rating,date,summary,body,recommend,reported,reviewer_name,reviewer_email,response,helpfulness

CREATE TABLE IF NOT EXISTS reviews (
  id BIGSERIAL NOT NULL,
  _id INT NOT NULL,
  product_id INT NOT NULL,
  rating SMALLINT NOT NULL,
  date TIMESTAMP NOT NULL,
  summary VARCHAR(150) NOT NULL,
  body VARCHAR(1000) NOT NULL,
  recommend BOOLEAN NOT NULL,
  reported BOOLEAN NOT NULL,
  reviewer_name VARCHAR(60) NOT NULL,
  reviewer_email VARCHAR(60) NOT NULL,
  response VARCHAR(1000),
  helpfulness INT NOT NULL,
  PRIMARY KEY(id)
);

COPY reviews(_id, product_id, rating, date, summary, body, recommend, reported, reviewer_name, reviewer_email, response, helpfulness)
FROM '/Users/anna/HackReactor/SDC/reviewsapi/data/reviews.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE IF NOT EXISTS photos (
  id BIGSERIAL NOT NULL,
  _id INT NOT NULL,
  review_id INT NOT NULL,
  url VARCHAR(200) NOT NULL,
  PRIMARY KEY(id),
  CONSTRAINT fk_review
    FOREIGN KEY(review_id)
      REFERENCES reviews(id)
);

COPY photos(_id, review_id, url)
FROM '/Users/anna/HackReactor/SDC/reviewsapi/data/reviews_photos.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE IF NOT EXISTS characteristic_review (
  id BIGSERIAL NOT NULL,
  _id INT NOT NULL,
  characteristic_id INT NOT NULL,
  review_id INT NOT NULL,
  value DECIMAL NOT NULL,
  PRIMARY KEY(id),
  CONSTRAINT fk_characteristic, fk_review
    FOREIGN KEY(characteristic_id, review_id)
      REFERENCES characteristics(id), reviews(id)
);

COPY characteristics(_id, characteristic_id, review_id, value)
FROM '/Users/anna/HackReactor/SDC/reviewsapi/data/characteristic_reviews.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE IF NOT EXISTS characteristics (
  id BIGSERIAL NOT NULL,
  _id INT NOT NULL,
  product_id INT NOT NULL,
  name VARCHAR(10) NOT NULL,
  PRIMARY KEY(id),
  CONSTRAINT fk_product
    FOREIGN KEY(product_id)
      REFERENCES reviews(product_id)
);

id,product_id,name

ALTER TABLE reviews
DROP COLUMN _id;

DELETE FROM reviews
WHERE (char_length(summary) < 60);

ALTER TABLE
ALTER COLUMN summary
TYPE VARCHAR(60);

DELETE FROM reviews
WHERE (char_length(body) < 50);

ALTER TABLE reviews
ADD CONSTRAINT body_check
CHECK (char_length(body) >= 50);


