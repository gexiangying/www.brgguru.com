<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>创建循环赛</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page">
			 <div data-role="content">
				<form action="robin_crt.lp" method="POST" autocomplete="off">
					<ul data-role="listview" data-insert="true">
						<li data-role="fieldcontain">
							<label for="tour_no">比赛ID</label>
							<input type="text" name="tour_no" id="tour_no">
						</li>
            <li data-role="fieldcontain">
							<label for="passwd">管理密码</label>
							<input type="password" name="passwd" id="passwd">
						</li>
            <li data-role="fieldcontain">
							<label for="teams">队伍数目</label>
							<input type="number" name="teams" id="teams">
						</li>
						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="a" >
						</li>
					</ul>
				</form>
			</div>
		</div>
	</body>
</html>

