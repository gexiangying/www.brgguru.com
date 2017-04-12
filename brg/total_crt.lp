<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>创建成绩统计表</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page">
			<div data-role="content">
				<% if not tour_no and not rounds then %>
			<form action="total_crt.lp" method="POST" autocomplete="off">
					<ul data-role="listview" data-insert="true">
						<li data-role="fieldcontain">
							<label for="tour_no">比赛ID</label>
							<input type="text" name="tour_no" id="tour_no">
						</li>
            <li data-role="fieldcontain">
							<label for="rounds">轮次</label>
							<input type="number" name="rounds" id="rounds" >
						</li>

						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="a" >
						</li>
					</ul>
				</form>
				<% else %>
				<%
					tour.crt_total(tour_no,rounds) %>
					<h4>添加比赛:(<%=tour_no %>)统计成功</h4>
				<% end %>
			</div>
			<%=tour.adminfooter %>
		</div>
	</body>
</html>

