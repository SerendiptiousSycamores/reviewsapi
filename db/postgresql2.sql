-- id,product_id,rating,date,summary,body,recommend,reported,reviewer_name,reviewer_email,response,helpfulness

CREATE TABLE IF NOT EXISTS reviews2 (
  id BIGSERIAL NOT NULL,
  _id INT NOT NULL,
  product_id INT NOT NULL,
  rating SMALLINT NOT NULL,
  date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  summary VARCHAR(150) NOT NULL,
  body VARCHAR(1000) NOT NULL,
  recommend BOOLEAN NOT NULL,
  reported BOOLEAN DEFAULT FALSE,
  reviewer_name VARCHAR(60) NOT NULL,
  reviewer_email VARCHAR(60) NOT NULL,
  response VARCHAR(1000),
  helpfulness INT DEFAULT 0,
  PRIMARY KEY(id)
);

COPY reviews2(_id, product_id, rating, date, summary, body, recommend, reported, reviewer_name, reviewer_email, response, helpfulness)
FROM '/Users/anna/HackReactor/SDC/reviewsapi/data/reviews.csv'
DELIMITER ','
CSV HEADER;



CREATE TABLE IF NOT EXISTS photos (
  id BIGSERIAL NOT NULL,
  _id INT NOT NULL,
  review_id INT NOT NULL,
  url VARCHAR(200) NOT NULL,
  PRIMARY KEY(id)
);
  CONSTRAINT fk_review
    FOREIGN KEY(review_id)
      REFERENCES review(id)
        ON DELETE CASCADE

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
  PRIMARY KEY(id)
);
  CONSTRAINT fk_characteristic, fk_review
    FOREIGN KEY(characteristic_id, review_id)
      REFERENCES characteristics(id), reviews(id)
        ON DELETE CASCADE

COPY characteristic_review(_id, characteristic_id, review_id, value)
FROM '/Users/anna/HackReactor/SDC/reviewsapi/data/characteristic_reviews.csv'
DELIMITER ','
CSV HEADER;


CREATE TABLE IF NOT EXISTS characteristics (
  id BIGSERIAL NOT NULL,
  _id INT NOT NULL,
  product_id INT NOT NULL,
  name VARCHAR(10) NOT NULL,
  PRIMARY KEY(id)
);
  CONSTRAINT fk_product
    FOREIGN KEY(product_id)
      REFERENCES reviews(product_id)

COPY characteristics(_id, product_id, name)
FROM '/Users/anna/HackReactor/SDC/reviewsapi/data/characteristics.csv'
DELIMITER ','
CSV HEADER;

ALTER TABLE review
DROP COLUMN _id;

DELETE FROM review
WHERE (char_length(summary) > 60);

ALTER TABLE reviews
ALTER COLUMN summary
TYPE VARCHAR(60);

DELETE FROM reviews
WHERE (char_length(body) < 50);

ALTER TABLE reviews
ADD CONSTRAINT body_check
CHECK (char_length(body) >= 50);

ALTER TABLE photos
ADD CONSTRAINT fk_review_id
FOREIGN KEY (review_id)
REFERENCES reviews(id)
ON DELETE CASCADE;


 DELETE FROM photos WHERE review_id in (SELECT review_id FROM del_reviews);


  SELECT json_object('{a,b}', '{1,2}');

    SELECT rating::text FROM (SELECT array_agg(rating) AS rating, array_agg(count) AS count FROM (SELECT rating, COUNT(rating) AS count FROM reviews WHERE product_id = 596348 AND reported = false GROUP BY rating ORDER BY rating ASC) AS ratings) AS result;


    SELECT json_object(rating, count) AS rating FROM (SELECT array_agg(rating) AS rating, array_agg(count) AS count FROM (SELECT rating::text, COUNT(rating)::text AS count FROM reviews WHERE product_id = 596348 AND reported = false GROUP BY rating ORDER BY rating ASC) AS ratings) AS result;

    SELECT json_object(recommend, count) AS recommended FROM (SELECT array_agg(recommend) AS recommend, array_agg(count) AS count FROM (SELECT recommend::int::text, COUNT(recommend)::text AS count FROM reviews WHERE product_id = 596346 AND reported = false GROUP BY recommend ORDER BY recommend ASC) AS recommended) AS result;

    SELECT c.name AS name , (SELECT ROW_TO_JSON(values) FROM (SELECT cr.characteristic_id AS id, AVG(cr.value)::numeric(10, 4)::text AS value) AS values) AS value FROM characteristic_review cr INNER JOIN characteristics c ON cr.characteristic_id = c.id WHERE c.product_id = 1 GROUP BY cr.characteristic_id, c.name ORDER BY cr.characteristic_id ASC;




    UPDATE reviews SET helpfulness = (helpfulness + 1) WHERE id = 3446546;

    DELETE FROM characteristics WHERE product_id NOT IN (SELECT DISTINCT product_id FROM reviews);

    DELETE FROM characteristic_review WHERE review_id NOT IN (SELECT id FROM reviews);

CREATE TABLE temp(
  id BIGSERIAL NOT NULL,
  _id INT NOT NULL,
  PRIMARY KEY(id)
);

INSERT INTO temp(_id)
SELECT id
FROM characteristic_review
WHERE review_id
NOT IN (SELECT id FROM reviews);

CREATE INDEX ON characteristic_review(review_id);
SELECT COUNT(id) FROM characteristic_review WHERE review_id IN (SELECT id FROM reviews);

CREATE TABLE del_review(
  id BIGSERIAL NOT NULL,
  _id INT NOT NULL,
  PRIMARY KEY(id)
);

INSERT INTO del_review(_id)
SELECT _id
FROM reviews
WHERE (CHAR_LENGTH(summary) > 60);

-- temp folder is to delete characteristics

INSERT INTO temp(_id)
SELECT _id
FROM characteristic_review
WHERE (review_id IN (SELECT _id FROM del_reviews2));

DROP INDEX characteristic_review_review_id_idx;

CREATE INDEX ON temp(_id);

DELETE FROM characteristic_review
WHERE id IN (SELECT _id FROM temp LIMIT 1000000);

DELETE FROM characteristic_review
WHERE id IN (SELECT _id FROM temp LIMIT 1000000);

DELETE FROM characteristic_review
WHERE id IN (SELECT _id FROM temp LIMIT 1000000);

DELETE FROM characteristic_review
WHERE id IN (SELECT _id FROM temp LIMIT 1000000);



SELECT
	pg_terminate_backend(pg_stat_activity.pid)
FROM
	pg_stat_activity
WHERE
	pg_stat_activity.datname = 'seed'
	AND pid <> pg_backend_pid();


SELECT characteristic_id::text AS id, AVG(value)::numeric(10, 4)::text AS value FROM characteristic_review GROUP BY characteristic_id FETCH FIRST 5 ROWS ONLY;

SELECT c.name AS name , (SELECT JSON_AGG(values) FROM (SELECT cr.characteristic_id::text AS id, AVG(cr.value)::numeric(10, 4)::text AS value) AS values)::text AS value FROM characteristic_review cr INNER JOIN characteristics c ON cr.characteristic_id = c.id WHERE c.product_id = 1 GROUP BY cr.characteristic_id, c.name ORDER BY cr.characteristic_id ASC;


SELECT ARRAY_AGG(c.name::text) AS name, (SELECT JSON_AGG(values) FROM (SELECT cr.characteristic_id::text AS id, AVG(cr.value)::numeric(10, 4)::text AS value) AS values)::text AS value FROM characteristic_review cr INNER JOIN characteristics c ON cr.characteristic_id = c.id WHERE c.product_id = 1 GROUP BY cr.characteristic_id ORDER BY cr.characteristic_id ASC;



SELECT ARRAY_AGG(c.name::text) AS name FROM characteristic_review cr INNER JOIN characteristics c ON cr.characteristic_id = c.id WHERE c.product_id = 1;

SELECT ARRAY_AGG((SELECT values FROM (SELECT cr.characteristic_id::text AS id, AVG(cr.value)::numeric(10, 4)::text AS value) AS values)) AS value FROM characteristic_review cr INNER JOIN characteristics c ON cr.characteristic_id = c.id WHERE c.product_id = 1 GROUP BY cr.characteristic_id, c.name ORDER BY cr.characteristic_id ASC;



SELECT c.name AS name , (SELECT ROW_TO_JSON(values) FROM (SELECT cr.characteristic_id::text AS id, AVG(cr.value)::numeric(10, 4)::text AS value) AS values)::text AS value FROM characteristic_review cr INNER JOIN characteristics c ON cr.characteristic_id = c.id WHERE c.product_id = 1 GROUP BY cr.characteristic_id, c.name ORDER BY cr.characteristic_id ASC;




SELECT ARRAY_AGG(DISTINCT c.name::text) AS name , (SELECT ROW_TO_JSON(values) FROM (SELECT cr.characteristic_id::text AS id, AVG(cr.value)::numeric(10, 4)::text AS value) AS values)::text AS value FROM characteristic_review cr INNER JOIN characteristics c ON cr.characteristic_id = c.id WHERE c.product_id = 1 GROUP BY cr.characteristic_id ORDER BY cr.characteristic_id ASC;

SELECT c.name AS name , (SELECT ROW_TO_JSON(values) FROM (SELECT cr.characteristic_id::text AS id, AVG(cr.value)::numeric(10, 4)::text AS value) AS values)::text AS value FROM characteristic_review cr INNER JOIN characteristics c ON cr.characteristic_id = c.id WHERE c.product_id = 1 GROUP BY cr.characteristic_id, c.name ORDER BY cr.characteristic_id ASC;



SELECT JSON_OBJECT(name, value) FROM (SELECT ARRAY_AGG(DISTINCT c.name::text) AS name , (SELECT JSON_AGG(values) FROM (SELECT cr.characteristic_id::text AS id, AVG(cr.value)::numeric(10, 4)::text AS value) AS values) AS value FROM characteristic_review cr INNER JOIN characteristics c ON cr.characteristic_id = c.id WHERE c.product_id = 1 GROUP BY cr.characteristic_id ORDER BY cr.characteristic_id ASC) AS characteristics;

SELECT ARRAY_AGG(DISTINCT c.name::text) AS name , (SELECT ARRAY_AGG(value_) FROM (SELECT JSON_AGG(values) FROM (SELECT cr.characteristic_id::text AS id, AVG(cr.value)::numeric(10, 4)::text AS value) AS values) AS value_) AS value FROM characteristic_review cr INNER JOIN characteristics c ON cr.characteristic_id = c.id WHERE c.product_id = 1 GROUP BY cr.characteristic_id ORDER BY cr.characteristic_id ASC;

SELECT ARRAY_AGG(DISTINCT c.name::text) AS name , (SELECT ARRAY_AGG(valueJ::text) FROM (SELECT JSON_AGG(values) FROM (SELECT cr.characteristic_id AS id, AVG(cr.value)::numeric(10, 4) AS value) AS values) AS valueJ) AS value FROM characteristic_review cr INNER JOIN characteristics c ON cr.characteristic_id = c.id WHERE c.product_id = 1 GROUP BY cr.characteristic_id ORDER BY cr.characteristic_id ASC;

SELECT JSON_OBJECT(name, value) as characteristics FROM (SELECT ARRAY_AGG(DISTINCT c.name::text) AS name , (SELECT ARRAY_AGG(valueJ::text) FROM (SELECT JSON_AGG(values) FROM (SELECT cr.characteristic_id AS id, AVG(cr.value)::numeric(10, 4) AS value) AS values) AS valueJ) AS value FROM characteristic_review cr INNER JOIN characteristics c ON cr.characteristic_id = c.id WHERE c.product_id = 1 GROUP BY cr.characteristic_id ORDER BY cr.characteristic_id ASC) AS characteristics;



SELECT JSON_OBJECT(name, value) FROM (SELECT ARRAY_AGG(DISTINCT c.name::text) AS name , (SELECT ARRAY_AGG(valueJ::text) FROM (SELECT JSON_AGG(values) FROM (SELECT cr.characteristic_id AS id, AVG(cr.value)::numeric(10, 4) AS value) AS values) AS valueJ) AS value FROM characteristic_review cr INNER JOIN characteristics c ON cr.characteristic_id = c.id WHERE c.product_id = 1 GROUP BY cr.characteristic_id ORDER BY cr.characteristic_id ASC) AS characteristics;


SELECT
(SELECT json_object(rating, count) AS rating FROM (SELECT array_agg(rating) AS rating, array_agg(count) AS count FROM (SELECT rating::text, COUNT(rating)::text AS count FROM reviews WHERE product_id = 594348 AND reported = false GROUP BY rating ORDER BY rating ASC) AS ratings) AS result) AS ratings,
(SELECT json_object(recommend, count) AS recommended FROM (SELECT array_agg(recommend) AS recommend, array_agg(count) AS count FROM (SELECT recommend::int::text, COUNT(recommend)::text AS count FROM reviews WHERE product_id = 596446 AND reported = false GROUP BY recommend ORDER BY recommend ASC) AS recommended) AS result) AS recommended;

    (SELECT json_object(rating, count) AS rating FROM (SELECT array_agg(rating) AS rating, array_agg(count) AS count FROM (SELECT rating::text, COUNT(rating)::text AS count FROM reviews WHERE product_id = 596348 AND reported = false GROUP BY rating ORDER BY rating ASC) AS ratings) AS result) AS ratings,

    (SELECT json_object(recommend, count) AS recommended FROM (SELECT array_agg(recommend) AS recommend, array_agg(count) AS count FROM (SELECT recommend::int::text, COUNT(recommend)::text AS count FROM reviews WHERE product_id = 596346 AND reported = false GROUP BY recommend ORDER BY recommend ASC) AS recommended) AS result) AS ratings,

    SELECT c.name AS name , (SELECT ROW_TO_JSON(values) FROM (SELECT cr.characteristic_id AS id, AVG(cr.value)::numeric(10, 4)::text AS value) AS values) AS value FROM characteristic_review cr INNER JOIN characteristics c ON cr.characteristic_id = c.id WHERE c.product_id = 94948 GROUP BY cr.characteristic_id, c.name ORDER BY cr.characteristic_id ASC;