#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import cgi
import datetime
import urllib
import webapp2
import json

from google.appengine.ext import ndb
from google.appengine.api import users

################################################################################
# @class Transaction
################################################################################
class Transaction(ndb.Model):
    """Models a Transaction entry with a user, merchant, category, amount, and date."""
    user = ndb.StringProperty()
    merchant = ndb.StringProperty()
    category = ndb.StringProperty()
    amount = ndb.IntegerProperty()
    date = ndb.DateTimeProperty(auto_now_add=True)

    @classmethod
    def query_user(cls, ancestor_key):
        return cls.query(ancestor=ancestor_key).order(-cls.date)

################################################################################
################################################################################
class MainPage(webapp2.RequestHandler):
    def get(self):
        self.response.out.write('<html><body>')
        user = self.request.get('user')
        ancestor_key = ndb.Key("User", user or "*notitle*")
        transactions = Transaction.query_user(ancestor_key).fetch(20)

        for trns in transactions:
            self.response.out.write('<div>' % trns.key())
        
        self.response.out.write("""<h3>Welcome to FIREd Up!</h3> <h4>Light a fire under your budget and illuminate the path to financial independence</h4> </body></html>""")#% (urllib.urlencode({'user': user}),cgi.escape(user)))

################################################################################
class User(webapp2.RequestHandler):
    def get(self,user):
        transactions = db.GqlQuery('SELECT * '
                             'FROM Transaction '
                             'WHERE ANCESTOR IS :1 '
                             'ORDER BY date DESC LIMIT 25',
                             user_key(user))
        
        json_array = []
        for trns in transactions:
            dict = {}
            dict['merchant'] = trns.merchant
            dict['category'] = trns.category
            dict['amount'] = str(trns.amount)
            dict['date'] = str(trns.date)
            json_array.append(dict)
        self.response.out.write(json.dumps({'results' : json_array}))

################################################################################
class Post(webapp2.RequestHandler):
    def post(self,user):
        transaction = Transaction(parent=ndb.Key("User",user or "*notitle$"),
                      user=user,
                      merchant=self.request.get('merchant'),
                      category=self.request.get('category'),
                      amount=self.request.get('amount'),
                      date=self.request.get('date'))

        #smaller_image = images.resize(self.request.get('image'), 300,300)
        #photo.image = ndb.BlobProperty(smaller_image)
        transaction.put()
        
        self.redirect('/%s' % user+ urllib.urlencode({'user': user}))


################################################################################
################################################################################
app = webapp2.WSGIApplication([('/', MainPage),
                               webapp2.Route('/post/<user>/', handler=Post, name='post-user'),
                               webapp2.Route('/<user>/', handler=User, name='user')],
                              debug=True)











