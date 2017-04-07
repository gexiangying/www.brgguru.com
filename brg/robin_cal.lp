<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>桥牌计分</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page" > 
			<div data-role="content">
				<form action="robin_cal.lp" method="post" autocomplete="off">
					<ul data-role="listview" data-insert="true">
						<li data-role="fieldcontain">
							<label for="tour_no">比赛ID</label>
								<input type="text" value="<% if tour_no then %><%=tour_no %><% end %>" name="tour_no" id="tour_no">
						</li>
						<li data-role="fieldcontain">
							<label for="round">轮次</label>
								<input type="text" value="<% if round then %><%=round %><% end %>" name="round" id="round">
						</li>
						<li data-role="fieldcontain">
							<label for="desk">桌号</label>
								<input type="text" value="<%if desk then %><%=desk %><% end %>" name="desk" id="desk">
						</li>
						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="b" />
						</li>
					</ul>
				</form>
			</div>

			<% if tour_no and round and desk then %>
			<%
      local desk1 = "a" .. desk
      local desk2 = "b" .. desk
			local open = tour.get_desk_sets(desk1,tour_no,round)
			local close = tour.get_desk_sets(desk2,tour_no,round)
      local index = {}
			tour.fill_index(index,open,1) 
			tour.fill_index(index,close,2) 
		  tour.cal_imp(index)	
			%> 
			<div data-role="content">
				<table width="100%" class="ui-responsive table-stripe" >
				<thead>
						<tr>
							<th></th>
							<th colspan="2">定约</th>
							<th colspan="2">得分</th>
							<th colspan="2">IMP</th>
						</tr>
						<tr>
							<th align="left">副序</th>
							<th >开室</th>
							<th >闭室</th>
							<th >开室</th>
							<th >闭室</th>
							<th ><%=desk1 %></th>
							<th ><%=desk2 %></th>
						</tr>
					</thead>
					<% local ns1,ns2 = tour.total_imp(index) 
					local keys = {}
          for k,v in _G.pairs(index) do 
              keys[#keys+1] = k												
					end
					_G.table.sort(keys)

           local db = tour.load_admin(tour_no) or {}
           local iround = _G.tonumber(round) 
					 local idesk = _G.tonumber(desk)
           db.rounds[iround][idesk].imp1 = ns1
           db.rounds[iround][idesk].imp2 = ns2
           db.rounds[iround][idesk].vp1 = tour.vp(#keys,ns1-ns2) 
           db.rounds[iround][idesk].vp2 = tour.vp(#keys,ns2-ns1) 
					 tour.save_admin(tour_no,db) 
					 %>
					<% for i,k in _G.ipairs(keys) do %>
					<% local v = index[k] %>
          <tr>
						<td><%=k %></td>
						<td><% if v[1] and v[1].str then %><%=v[1].str %><% end %></td>
						<td><% if v[2] and v[2].str then %><%=v[2].str %><% end %></td>
						<td><% if v[1] and v[1].score then %><%=v[1].score%><% end %></td>
						<td><% if v[2] and v[2].score then %><%=v[2].score%><% end %></td>
						<td><% if v[1] and v[1].imp then %><%=v[1].imp %><% end %></td>
						<td><% if v[2] and v[2].imp then %><%=v[2].imp %><% end %></td>
					</tr>
					<% end %>
					<tr>
						<td>总计</td>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td><%=ns1 %></td>
						<td><%=ns2 %></td>
					</tr>
					<tr>
						<td>VP</td>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td><%=tour.vp(#keys,ns1-ns2) %></td>
						<td><%=tour.vp(#keys,ns2-ns1) %></td>
					</tr>

				</table>
			</div>
			<% end %>
			</div>
	</body>
</html>	
