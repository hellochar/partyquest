
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('controller');
};

exports.game = function(req, res) {
  res.render('game');
};
