<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>创建队式赛</title> 
    <%=tour.head %>
	</head> 
	<body>
    <%
      local db = {} 
			%>
		<div data-role="page">
			 <%=tour.header %>
			 <div data-role="content">
       <% if not tour_no or not passwd or not rounds or not desks then %>
					<h4>请输入比赛ID和管理密码和轮次，桌数</h4>
       <% else 
           db = tour.load_admin(tour_no) or {}
           if db.admin and db.admin ~= passwd then
       %>
          <h4>比赛已存在</h4>
           <% else %>
           <% db.admin = passwd 
				 tour.save_admin(tour_no,db) 
				 tour.add_tour(tour_no,rounds,desks,"team")
				 %>
          <h4>创建比赛<%=tour_no %>成功</h4>
          <% end %>
       <% end %>
			</div>
      <%=tour.footer %>
		</div>
	</body>
</html>

