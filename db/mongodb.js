import mongoose from 'mongoose';
const { Schema, model } = mongoose;

const PhotoShema = new Schema ({
  url: {
    type: String,
    required: false
  }
});

const CharacteristicSchema = new Schema ({
  name: {
    type: String,
    required: true
  },
  characteristicsId: {
    type: Number,
    required: true
  },
  value: {
    type: Number,
    required: true
  }
});

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
  photos: [PhotoSchema],
  characteristics: {CharacteristicSchema}
  }
});

module.exports Review = model('review', ReviewSchema);
