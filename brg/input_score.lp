<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>导入成绩表</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page">
			<%=tour.header %>
			 <div data-role="content">
				<% if not tour_no or not no or not round then %>
				<h1>输入信息不全</h1>
				<% else %>
				<% local ok = tour.input_score(tour_no,no,round) %>
				<% if ok then ok="成功" else ok="不成功" end %>
				<h1>导入<%=ok%></h1>
				<% end %>
			 </div>
			 <%=tour.adminfooter %>
		</div>
	</body>
</html>

