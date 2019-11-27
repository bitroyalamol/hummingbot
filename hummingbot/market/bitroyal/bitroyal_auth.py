import base64
from typing import Dict


class BitroyalAuth:
    """
    Auth class required by Bitroyal API
    Learn more at https://alphapoint.github.io/slate/#introduction
    """
    def __init__(self, user_name: str, pass_word: str):
        self.user_name = user_name
        self.pass_word = pass_word

    def generate_auth_dict(self) -> Dict[str, any]:
        pass

    def get_headers(self) -> Dict[str, any]:
        """
        Generates authentication headers required by BIROYAL
        :return: a dictionary of auth headers
        """
        user_pass = bytes(self.user_name + ':' + self.pass_word, 'utf8')
        pass_key = base64.b64encode(user_pass).decode('utf8')
        return {
            "Authorization": "Basic {}".format(pass_key),
            "Content-Length": "0",
            "Content-Type": 'application/json',
        }
