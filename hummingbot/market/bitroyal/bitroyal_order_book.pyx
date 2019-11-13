#!/usr/bin/env python
import ujson
import logging
from typing import (
    Dict,
    List,
    Optional,
)

from sqlalchemy.engine import RowProxy
import pandas as pd

from hummingbot.logger import HummingbotLogger
from hummingbot.core.data_type.order_book cimport OrderBook
from hummingbot.core.data_type.order_book_message import (
    BitroyalOrderBookMessage,
    OrderBookMessage,
    OrderBookMessageType
)

_cbpob_logger = None


cdef class BitroyalOrderBook(OrderBook):
    @classmethod
    def logger(cls) -> HummingbotLogger:
        global _cbpob_logger
        if _cbpob_logger is None:
            _cbpob_logger = logging.getLogger(__name__)
        return _cbpob_logger

    @classmethod
    def snapshot_message_from_exchange(cls,
                                       msg: Dict[str, any],
                                       timestamp: float,
                                       metadata: Optional[Dict] = None) -> OrderBookMessage:
        """
        *required
        Convert json snapshot data into standard OrderBookMessage format
        :param msg: json snapshot data from live web socket stream
        :param timestamp: timestamp attached to incoming data
        :return: BitroyalOrderBookMessage
        """
        if metadata:
            msg.update(metadata)
        return BitroyalOrderBookMessage(
            message_type=OrderBookMessageType.SNAPSHOT,
            content=msg,
            timestamp=timestamp
        )

    @classmethod
    def diff_message_from_exchange(cls,
                                   msg: Dict[str, any],
                                   timestamp: Optional[float] = None,
                                   metadata: Optional[Dict] = None) -> OrderBookMessage:
        """
        *required
        Convert json diff data into standard OrderBookMessage format
        :param msg: json diff data from live web socket stream
        :param timestamp: timestamp attached to incoming data
        :return: BitroyalOrderBookMessage
        """
        if metadata:
            msg.update(metadata)
        if "time" in msg:
            msg_time = pd.Timestamp(msg["time"]).timestamp()
        return BitroyalOrderBookMessage(
            message_type=OrderBookMessageType.DIFF,
            content=msg,
            timestamp=timestamp or msg_time)

    @classmethod
    def snapshot_message_from_db(cls, record: RowProxy, metadata: Optional[Dict] = None) -> OrderBookMessage:
        """
        *used for backtesting
        Convert a row of snapshot data into standard OrderBookMessage format
        :param record: a row of snapshot data from the database
        :return: BitroyalOrderBookMessage
        """
        msg = record.json if type(record.json)==dict else ujson.loads(record.json)
        return BitroyalOrderBookMessage(
            message_type=OrderBookMessageType.SNAPSHOT,
            content=msg,
            timestamp=record.timestamp * 1e-3
        )

    @classmethod
    def diff_message_from_db(cls, record: RowProxy, metadata: Optional[Dict] = None) -> OrderBookMessage:
        """
        *used for backtesting
        Convert a row of diff data into standard OrderBookMessage format
        :param record: a row of diff data from the database
        :return: BitroyalOrderBookMessage
        """
        return BitroyalOrderBookMessage(
            message_type=OrderBookMessageType.DIFF,
            content=record.json,
            timestamp=record.timestamp * 1e-3
        )

    @classmethod
    def trade_receive_message_from_db(cls, record: RowProxy, metadata: Optional[Dict] = None):
        """
        *used for backtesting
        Convert a row of trade data into standard OrderBookMessage format
        :param record: a row of trade data from the database
        :return: BitroyalOrderBookMessage
        """
        return BitroyalOrderBookMessage(
            OrderBookMessageType.TRADE,
            record.json,
            timestamp=record.timestamp * 1e-3
        )

    @classmethod
    def from_snapshot(cls, snapshot: OrderBookMessage):
        raise NotImplementedError("Bitroyal order book needs to retain individual order data.")

    @classmethod
    def restore_from_snapshot_and_diffs(self, snapshot: OrderBookMessage, diffs: List[OrderBookMessage]):
        raise NotImplementedError("Bitroyal order book needs to retain individual order data.")