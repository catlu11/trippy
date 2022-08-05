Parse.Cloud.define("averageItineraryRadius", async (request) => {
  const query = new Parse.Query("Itinerary");
  const results = await query.find();
  let sum = 0;
  for (let i = 0; i < results.length; ++i) {
    sum += results[i].get("radius");
  }
  return sum / results.length;
});
