CREATE DATABASE reviewsAPI;

CREATE TABLE IF NOT EXISTS reviews (
  id BIGSERIAL NOT NULL,
  product_id INT NOT NULL,
  rating SMALLINT NOT NULL,
  summary VARCHAR(60) NOT NULL,
  recommend BOOLEAN NOT NULL,
  response VARCHAR(1000),
  body VARCHAR(1000) NOT NULL,
  date TIMESTAMP NOT NULL,
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

CREATE TABLE IF NOT EXISTS characteristics (
  id SERIAL NOT NULL,
  characteristic_id SMALLINT NOT NULL,
  type VARCHAR(10) NOT NULL,
  value DECIMAL NOT NULL,
  review_id INT NOT NULL,
  PRIMARY KEY(id),
  CONSTRAINT fk_review
    FOREIGN KEY(review_id)
      REFERENCES reviews(id)
);