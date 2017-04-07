<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<% local url = _G.require("lpp.url") %>
<html> 
	<head> 
		<title>锁定记录</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page">
			<%=tour.header %>
			 <div data-role="content">
				 <% if not tour_no then %>
				 <h2>比赛列表:</h2>
				<ol data-role="listview">
					<% local tour_list = tour.load_tour_list() 
				     for k,v in _G.pairs(tour_list) do 
				local linkname = "edit.lp?tour_no=" .. url.escape(k) %>
				<li> <a href="<%=linkname %>"><%=k %></a></li>
					<% end %>
				</ol>
				 <% elseif not round then %>
				 <h2>轮次:</h2>
				<ol data-role="listview">
					<% local tour_list = tour.load_tour_list() 
				local t = tour_list[tour_no] or {} 
				for i=1,t.rounds do
				local linkname = "edit.lp?tour_no=" .. url.escape(tour_no) .. "&round=" .. i%>
				<li> <a href="<%=linkname %>">第<%=i %>轮</a></li>
				<% end %>
				<% local linkname = "edit.lp?tour_no=" .. url.escape(tour_no) .. "&round=" .. 0%>
				<li> <a href="<%=linkname %>">所有轮次</a></li>
				</ol>
				 <% elseif not desk then %>
				 <h2>桌号:</h2>
				<ol data-role="listview">
					<% local tour_list = tour.load_tour_list() 
				local t = tour_list[tour_no] or {} 
				for i=1,t.desks do
				local linkname = "edit.lp?tour_no=" .. url.escape(tour_no) .. "&round=" .. round .. "&desk=" .. i%>
				<li> <a href="<%=linkname %>">第<%=i %>桌</a></li>
				<% end %>
				<% local linkname = "edit.lp?tour_no=" .. url.escape(tour_no) .. "&round=" .. round .. "&desk=" .. 0%>
				<li> <a href="<%=linkname %>">所有桌</a></li>
				</ol>
				<% else %>
				<form action="lock.lp" method="POST" autocomplete="off">
					<ul data-role="listview" data-insert="true">
            <li data-role="fieldcontain">
							<label for="passwd">密码</label>
							<input type="password" name="passwd" id="passwd">
						</li>
						<input type="hidden" name="tour_no" value="<%=tour_no %>" >
						<input type="hidden" name="round" value="<%=round %>" >
						<input type="hidden" name="desk" value="<%=desk %>" >
						<input type="hidden" name="unlocked" value="unlock" >
						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="a" />
						</li>
					</ul>
				</form>
				<% end %>
			</div>
			<%=tour.footer %>
		</div>
	</body>
</html>

