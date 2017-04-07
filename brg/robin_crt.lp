<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>循环赛</title> 
    <%=tour.head %>
	</head> 
	<body>
    <%
      local db = {} 
			%>
		<div data-role="page">
			 <div data-role="content">
       <% if not tour_no or not passwd or not teams then %>
					<h4>请输入比赛ID,管理密码,队伍数目</h4>
       <% else 
           db = tour.load_admin(tour_no) or {}
           if db.admin then
       %>
          <h4>比赛已存在</h4>
           <% else %>
           <% db.admin = passwd 
				 db.teams = _G.tonumber(teams)
				 for i=1,db.teams do
				  db.team = db.team or {}
				  db.team[i] = {}
				  db.team[i].no = i
				  db.team[i].name = _G.tostring(i)
				 end
				 db.rounds = {}
				 local rs = tour.bgl(db.teams)
         for i,v in _G.ipairs(rs) do
				 db.rounds[i] = db.rounds[i] or {}
				 local desk = 1
				   for k=1,#(v),2 do
				     db.rounds[i][desk] = {}
				     db.rounds[i][desk].t1 = v[k]
				     db.rounds[i][desk].t2 = v[k+1]
				     db.rounds[i][desk].imp1 = 0
				     db.rounds[i][desk].imp2 = 0
				     db.rounds[i][desk].vp1 = 0
				     db.rounds[i][desk].vp2 = 0
				     db.rounds[i][desk].bonus1 = 0
				     db.rounds[i][desk].bonus2 = 0
				     desk = desk + 1
				   end
				 end 
				 tour.save_admin(tour_no,db) %>
          <h4>创建比赛<%=tour_no %>成功</h4>
          <% end %>
       <% end %>
			</div>
		</div>
	</body>
</html>

