<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<% local url = _G.require("lpp.url") %>
<html> 
	<head> 
		<title>轮空录入</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page" > 
      <%=tour.header %>
			<div data-role="content">
			<% if not tour_no then %>
				<h2>比赛列表:</h2>
			<ol data-role="listview">
			<% local tour_list = tour.load_tour_list()
				for k,v in _G.pairs(tour_list) do 
			  if v.tour_type and v.tour_type == "team" then
				local linkname = "bonus.lp?tour_no=" .. url.escape(k) %>
				<li> <a href="<%=linkname %>"><%=k %></a></li>
				<% end %>
				<% end %>
			</ol>
			<% elseif not round then %>
			<h2>轮次:</h2>
				<ol data-role="listview">
					<% local tour_list = tour.load_tour_list() 
				local t = tour_list[tour_no] or {} 
				for i=1,t.rounds do
				local linkname = "bonus.lp?tour_no=" .. url.escape(tour_no) .. "&round=" .. i%>
				<li> <a href="<%=linkname %>">第<%=i %>轮</a></li>
				<% end %>
				</ol>
			<% end %>
			</div>		
			<% if tour_no and round and not desks then %>
			<div data-role="content">
				<form action="bonus.lp" method="POST" autocomplete="off">
					<ul data-role="listview" data-insert="true">
						<li data-role="fieldcontain">
							<label for="no1">编号</label>
							<input type="number" name="no1" id="no1">
						</li>
						<li data-role="fieldcontain">
							<label for="no2">编号</label>
							<input type="number" name="no2" id="no2">
						</li>
						<li data-role="fieldcontain">
							<label for="desks">桌数</label>
							<input type="number" name="desks" id="desks">
						</li>
						<input type="hidden" name="tour_no" value="<%=tour_no %>" >
						<input type="hidden" name="round" value="<%=round %>" >
						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="a" >
						</li>
					</ul>
				</form>
			</div>
			<%elseif tour_no and round and desks and no1 and no2 then %>
			<% tour.add_bonus(tour_no,round,no1,no2,desks) %>
			<% local users = tour.load_user_list() %>
			<h4>添加轮空结果:轮次:<%=round %> <%=users[_G.tonumber(no1)] %> <%=users[_G.tonumber(no2)] %> </h4>
			<% end %>
			<%=tour.adminfooter %>
		</div>
	</body>
</html>	
