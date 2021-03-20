CREATE DATABASE reviews_api;

-- id,product_id,rating,date,summary,body,recommend,reported,reviewer_name,reviewer_email,response,helpfulness

CREATE TABLE IF NOT EXISTS reviews_temp (
  id BIGSERIAL NOT NULL,
  _id INT NOT NULL,
  product_id INT NOT NULL,
  rating SMALLINT NOT NULL,
  date TIMESTAMP NOT NULL,
  summary VARCHAR(60) NOT NULL,
  recommend BOOLEAN NOT NULL,
  reported BOOLEAN NOT NULL,
  reviewer_name VARCHAR(60) NOT NULL,
  reviewer_email VARCHAR(60) NOT NULL,
  response VARCHAR(1000),
  body VARCHAR(1000) NOT NULL,
  helpfulness INT NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS reviews (
  id BIGSERIAL NOT NULL,
  product_id INT NOT NULL,
  rating SMALLINT NOT NULL,
  date TIMESTAMP NOT NULL,
  summary VARCHAR(60) NOT NULL,
  recommend BOOLEAN NOT NULL,
  response VARCHAR(1000),
  body VARCHAR(1000) NOT NULL,
  reviewer_name VARCHAR(60) NOT NULL,
  helpfulness INT NOT NULL,
  PRIMARY KEY(id)
);



CREATE TABLE IF NOT EXISTS photos (
  id SERIAL NOT NULL,
  review_id INT NOT NULL,
  url VARCHAR(200) NOT NULL,
  PRIMARY KEY(id),
  CONSTRAINT fk_review
    FOREIGN KEY(review_id)
      REFERENCES reviews(id)
);

CREATE TABLE IF NOT EXISTS photos (
  id SERIAL NOT NULL,
  review_id INT NOT NULL,
  url VARCHAR(200) NOT NULL,
  PRIMARY KEY(id),
  CONSTRAINT fk_review
    FOREIGN KEY(review_id)
      REFERENCES reviews(id)
);

-- id,review_id,url

CREATE TABLE IF NOT EXISTS characteristics (
  id SERIAL NOT NULL,
  characteristic_id SMALLINT NOT NULL,
  review_id INT NOT NULL,
  value DECIMAL NOT NULL,
  PRIMARY KEY(id),
  CONSTRAINT fk_review
    FOREIGN KEY(review_id)
      REFERENCES reviews(id)
);

-- id,characteristic_id,review_id,value