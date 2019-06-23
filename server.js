const express = require("express");

const app = express();
const port = 3000;
const { articles } = require(__dirname + "/json/articles.json");
const punctuation = /[.,\/#!$%\^&\*;:{}=\-_`~()]/g;
const shouldFail = () => Math.random() * 100 > 90;

const byQuery = q => article => {
  if (!q) return true;

  const searchWords = q.toLowerCase().split(" ");
  const descriptionContainsQuery = searchWords.reduce((acc, word) => {
    const descriptionWords = article.description
      .toLowerCase()
      .replace(punctuation, "")
      .split(" ");
    return acc || descriptionWords.includes(word);
  }, false);

  return descriptionContainsQuery;
};

const byType = types => article => {
  if (!types) return true;

  const searchTypes = types.toLowerCase().split(" ");
  const articleHasSearchedTypes = searchTypes.reduce((acc, type) => {
    return acc || article.types.includes(type);
  }, false);

  return articleHasSearchedTypes;
};

app.get("/articles", (req, res) => {
  if (shouldFail()) {
    return res.status(418).send("Here's my handle, here's my spout!");
  }

  const { q, types } = req.query;
  const result = articles.filter(byQuery(q)).filter(byType(types));

  res.setHeader("Access-Control-Allow-Origin", "*");

  return res.send(result);
});

app.listen(port, () => console.log(`Open for business on port ${port}!`));
