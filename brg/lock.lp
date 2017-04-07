<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>

<html> 
	<head> 
		<title>解锁记录</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page">
			<%=tour.header %>
	 <div data-role="content">
		 <%
			 if desk == "0" then desk = nil end
			 if round == "0" then round = nil end
			 %>
    <% if not tour_no or not passwd then %>
    <h4>请输入比赛ID 和管理密码</h4>
    <% else %>
    <%
      local db = tour.load_admin(tour_no)
      if not db.admin then 
     %>
        <h4>比赛<%=tour_no %>尚未创建</h4>
      <% elseif not desk and db.admin ~= passwd then %>
        <h4>管理密码不对</h4>
			<% elseif desk and not tour.auth_desk(tour_no,round,desk,passwd) then %>
			  <h4>牌桌密码不对</h4>
      <% elseif unlocked then %>
        <% tour.unlock_tour(db,tour_no,round,desk) %>
        <% tour.save_admin(tour_no,db) %>
        <h4>解锁</h4>
      <% else %>
        <% tour.lock_tour(db,tour_no,round,desk) %>
        <% tour.save_admin(tour_no,db) %>
        <h4>锁定</h4>
      <% end %>
    <% end %>  
   </div>
		<%=tour.footer %>
		</div>
	</body>
</html>

