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
				 <form action="input_score.lp" method="POST" autocomplete="off" data-ajax="false">
					<ul data-role="listview" data-insert="true">
						<li data-role="fieldcontain">
							<label for="tour_no">比赛名称</label>
							<input type="text" name="tour_no" id="tour_no">
						</li>
						<li data-role="fieldcontain">
							<label for="no">单次比赛ID</label>
							<input type="text" name="no" id="no">
						</li>
						<li data-role="fieldcontain">
							<label for="round">场次</label>
							<input type="text" name="round" id="round">
						</li>
						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="a" >
						</li>
					</ul>
				</form>

			 </div>
			 <%=tour.adminfooter %>
		</div>
	</body>
</html>

