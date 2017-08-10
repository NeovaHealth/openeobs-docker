# -*- coding: utf-8 -*-
"""
Uses timeit to call ERPpeek's `execute_kw` method.

http://erppeek.readthedocs.io/en/latest/api.html#erppeek.Client.execute_kw

This method in turn is just a wrapper for Odoo's `execute_kw` method exposed as
part of it's Web Service API.

https://www.odoo.com/documentation/8.0/api_integration.html#calling-methods
"""
import timeit
import logging


logging.basicConfig(filename='logs/erppeek_timer.log', level=logging.DEBUG)
_logger = logging.getLogger(__name__)


class ErpPeekTimer:

    @classmethod
    def wrap_in_escaped_quotes(cls, foo):
        return '"{}"'.format(foo)

    def __init__(self, model, method, login='admin', odoo_host='http://localhost:8069', database='develop'):
        self.model = self.wrap_in_escaped_quotes(model)
        self.method = self.wrap_in_escaped_quotes(method)
        setup = 'import erppeek'
        setup += '\n'
        setup += 'import uuid'
        setup += '\n'
        setup += "erppeek_client = erppeek.Client('{odoo_host}', db='{database}', user='{user}', password='{password}')".format(user=login, password=login, odoo_host=odoo_host, database=database)
        self.setup = setup

    def timeit(self, args_string, repeat=3):
        """
        Run the ErpPeekTimer instance's assigned method and log the time it
        takes to complete.
        :param args_string: Python arguments in string form. The first argument
        :param repeat:
        :return:
        """
        statement = "erppeek_client.execute_kw({model}, {method}, {args_string})"
        statement = statement.format(
            model=self.model, method=self.method, args_string=args_string
        )
        return timeit.repeat(statement, self.setup, repeat=repeat, number=1)

    def log_before(self, repeat):
        _logger.info(
            "Executing {model}.{method} {repeat} times...".format(
                model=self.model, method=self.method, repeat=repeat
            )
        )

    @classmethod
    def log_after(cls, timings):
        average = sum(timings) / len(timings)
        _logger.info("{}s average".format(average))
        minimum = min(timings)
        _logger.info("{}s min\n".format(minimum))

    def timeit_and_log(self, args_string, repeat=3):
        self.log_before(repeat)
        timings = self.timeit(args_string)
        self.log_after(timings)
