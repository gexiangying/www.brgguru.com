<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>管理后台</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page">
				<ol data-role="listview">
					<li> <a href="adduser.lp">人员管理</a></li>
					<li> <a href="ximp.lp">全场计算</a></li>
					<li> <a href="bonus.lp">轮空录入</a></li>
				</ol>
			<%=tour.adminfooter %>
		</div>
	</body>
</html>

