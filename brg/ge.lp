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
					<li> <a href="edit_register.lp">编辑报名表</a></li>
					<li> <a href="total_crt.lp">创建总成绩表</a></li>
					<li> <a href="input_score_form.lp">导入成绩</a></li>
					<li> <a href="edit_total.lp">编辑总成绩</a></li>
				</ol>
			<%=tour.adminfooter %>
		</div>
	</body>
</html>

