<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>循环赛结果</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page">
			<div data-role="content">
				<form action="rs.lp" method="POST" autocomplete="off">
					<ul data-role="listview" data-insert="true">
						<% if not tour_no then  %>
						<li data-role="fieldcontain">
							<label for="tour_no">比赛ID</label>
							<input type="text" name="tour_no" id="tour_no">
						</li>
						<% else %>
						<input type="hidden" name="tour_no" value="<%=tour_no %>"/>
						<% end %>
						<li data-role="fieldcontain">
							<label for="round">轮次</label>
							<% if round then %>
							<input type="number" name="round" id="round" value="<%=round %>">
							<% else %>
							<input type="number" name="round" id="round">
							<% end %>
						</li>
						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="a" >
						</li>
					</ul>
				</form>
			</div>
			<%
		 local db = {}																		 
     if tour_no and round then
		 db = tour.load_admin(tour_no) or {}																		 
     round = _G.tonumber(round)
     if round >= db.teams then round = 1 end
																					 %>
			<div data-role="content">
				<table width="100%" class="ui-responsive table-stripe" >
					<thead>
						<tr>
							<th >桌号</th>
							<th >主队</th>
							<th >客队</th>
							<th >imp</th>
							<th >vp</th>
							<th >罚分</th>
						</tr>
					</thead>
					<tbody>
						<% for i,v in _G.ipairs(db.rounds[round]) do %>
						<tr>
							<td>第<%=i %>台</td>
							<td><%=db.team[v.t1].name %></td>
							<td><%=db.team[v.t2].name %></td>
							<td><%=v.imp1 %>:<%=v.imp2 %></td>
							<td><%=v.vp1 %>:<%=v.vp2 %></td>
							<td><%=v.bonus1 %>:<%=v.bonus2 %></td>
						</tr>
						<% end %>
          </tbody>
				</table>
			</div>
			<%
			local rs = {}
      for i=1,round do
			  for k,v in _G.ipairs(db.rounds[i]) do 
				  rs[v.t1] = rs[v.t1] or {}
					rs[v.t1].no = v.t1
					rs[v.t1].vp = rs[v.t1].vp or 0
					rs[v.t1].vp = rs[v.t1].vp + v.vp1 + v.bonus1
				  rs[v.t2] = rs[v.t2] or {}
					rs[v.t2].no = v.t2
					rs[v.t2].vp = rs[v.t2].vp or 0
					rs[v.t2].vp = rs[v.t2].vp + v.vp2 + v.bonus2
				end
			end
			_G.table.sort(rs,function(a,b) return a.vp > b.vp end)
			%>
			<div data-role="content">
				<table width="100%" class="ui-responsive table-stripe" >
					<thead>
						<tr>
							<th >名次</th>
							<th >队伍</th>
							<th >vp</th>
						</tr>
					</thead>
					<tbody>
						<% for i,v in _G.ipairs(rs) do %>
						<tr>
						<td>第<%=i %>名</td>
						<td><%=db.team[v.no].name %></td>
						<td><%=v.vp %></td>
						<% end %>
					</tbody>
				</table>
			</div>	
     <% end %>	
		</div>
	</body>
</html>

