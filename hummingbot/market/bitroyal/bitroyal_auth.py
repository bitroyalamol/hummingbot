import time
import hmac
import hashlib
import base64
import requests
from typing import Dict



class BitroyalAuth:
    """
    Auth class required by Bitroyal API
    Learn more at https://alphapoint.github.io/slate/#introduction
    """
    def __init__(self, username: str, password: str):
        self.username = username
        self.password = password

    def generate_auth_dict(self) -> Dict[str, any]:
        """
        Generates authentication signature and return it in a dictionary along with other inputs
        :return: a dictionary of request info including the request signature
        """
        #timestamp = str(time.time())
        #message = timestamp + method.upper() + path_url + body
        user_pass = "self.username:self.password"
        #hmac_key = base64.b64decode(self.secret_key)
        #signature = hmac.new(hmac_key, message.encode('utf8'), hashlib.sha256)
        pass_b64 = base64.b64encode(user_pass).decode("ascii")

        return {
            "auth": pass_b64,
        }

    def get_headers(self) -> Dict[str, any]:
        """
        Generates authentication headers required by coinbasse
        :param method: GET / POST / etc.
        :param path_url: e.g. "/accounts"
        :param body: request payload
        :return: a dictionary of auth headers
        """
        header_dict = self.generate_auth_dict()
        return {
            "Authorization": "Basic {}".format(header_dict["auth"]),
            "Content-Length": 0,
            "Content-Type": 'application/json',
        }

r=requests.post("https://apicoinmartprod.alphapoint.com:8443/AP/Authenticate", headers=BitroyalAuth.get_headers())
print(r)