$(document).ready(function(){
  $("form").on("submit", function(e){
    e.preventDefault()
		var data = $("form").serialize();
		$.post("/sentence-submit", data, function(response){
			var domText = "<p>" + response + "</p>";
			$(".translation-container").append(domText);
		})
	})
})
