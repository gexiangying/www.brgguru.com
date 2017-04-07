<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<% local txs = _G.require("brg.txs") %>
<html> 
	<head> 
		<title>创建通讯赛</title> 
		<%=tour.head %>
	</head> 
	<body>
		<%
		local db = {} 
		%>
		<div data-role="page">
			<div data-role="content">
				<% if not tour_no or not passwd or not desks then %>
				<h4>请输入比赛ID和管理密码 比赛桌数</h4>
				<% else 
				db = tour.load_admin(tour_no) or {}
				if db.admin and db.admin ~= passwd then
				%>
				<h4>比赛已存在</h4>
				<% else %>
				<% 
				db.admin = passwd 
				db.desks = _G.tonumber(desks)
				db.rounds = txs.get_rounds(_G.tonumber(desks))
				db.type = "txs"
				db.round = txs.txs_round(_G.tonumber(desks))
				tour.save_admin(tour_no,db) 
				tour.add_tour(tour_no,db.rounds,db.desks,"txs")
				%>
				<h4>创建比赛<%=tour_no %>成功</h4>
				<% end %>
				<% end %>
			</div>
			<%=tour.footer %>
		</div>
	</body>
</html>

