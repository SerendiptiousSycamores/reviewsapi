import mongoose from 'mongoose';
const { Schema, model } = mongoose;

const ReviewSchema = new Schema({
  product_id: {
    type: Number,
    required: true
  },
  rating: {
    type: Number,
    required: true
  },
  summary: {
    type: String,
    maxLength:60,
    required: true
  },
  recommend: {
    type: Boolean,
    required: true
  },
  response: {
    type: String,
    required: false
  },
  body: {
    type: String,
    minLength: 50,
    maxLength: 1000,
    required: true
  },
  date: {
    type: Date,
    default: Date.now
  },
  reviewer_name: {
    type: String,
    required: true
  },
  helpfulness: {
    type: Number,
    required: true
  },
  photos: [{
    type: String,
    required: false
  }],
  characteristics: {
    Size: {
      type: Number,
      required: true
    },
    Width: {
      type: Number,
      required: true
    },
    Comfort: {
      type: Number,
      required: true
    }
  }
});

module.exports Review = model('review', ReviewSchema);
