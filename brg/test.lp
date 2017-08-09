<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>桥牌计分</title> 
		<%=tour.head %>
<script>
$(document).on("pagecreate","#page1",function(){
  $("#btn1").on("click",function(){
    $("#test1").load("test1.lp");
  });                       
});
</script>

	</head> 
	<body>
		<div data-role="page" id="page1">
			<h3 id="test1">hello world!</h3>
			<button id="btn1" type="button">Load</button>
		<%=tour.footer %>
		</div>
	</body>
</html>

